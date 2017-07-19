#!/usr/bin/ruby

#utils
def check_git_status
	git_status = `git status --porcelain`
	if git_status.length > 0
		print_error 'You appear to have something uncommitted. Please check \'git status\'.'
		exit 1
	end

	git_branch = `git status --porcelain -b`
	if !(git_branch.include? 'master')
		print_error 'You do not appear to be in master. Please check \'git status\'.'
		exit 1
	end
end

def print_error msg
	puts "BE CALM: #{msg}"
end

def ask_user msg
	puts msg
	puts "Continue? y/n"
	dialog_result = $stdin.gets.chomp!
	if dialog_result != 'y'
		print_error 'Aborted by user.'
		exit 1
	end
end

def verify_pod
	puts "Pod validation process started..."

	lint_result = `pod lib lint --no-clean --allow-warnings --sources='git@github.com:Humanifydev/SDK-iOS-specs.git,https://github.com/CocoaPods/Specs'`
	error = lint_result[/^[[:space:]]*\[!\].*did not pass validation/]

	# It isn't nil or empty
	if error.to_s != ''
  		# print 'pod lib lint' log
		puts "\n<log_begin>\n "
		puts lint_result
		puts "\n<log_end>\n "

		print_error 'Error occurred during the validation. Please check the log carefully for errors.'
		exit 1
	end

	puts "Pod validation process finished successfully."
end

def check_pod_log_for_errors log
	error = log[/^[[:space:]]*\-[[:space:]]*ERROR[[:space:]]*\|/]

	# It isn't nil or empty
	if error.to_s != ''
  		# print log
		puts "\n<log_begin>\n "
		puts log
		puts "\n<log_end>\n "

		print_error 'Error occurred during the process. Please check the log carefully for errors.'
		exit 1
	end
end

# --prepare
# read version number from input, if no - abort with error msg
if ARGV.length < 2
	print_error 'Enter podspec file name and new pod version as parameters.'
	exit 1
end

#check if pointed podspec file exist
podspec_filename = ARGV[0]
if !File.exist? podspec_filename
	print_error "File #{podspec_filename} not found."
	exit 1
end

# show confirm with deploy message and version number
new_pod_version = ARGV[1]
ask_user "I'm going to deploy current podspec with new version number: #{new_pod_version}."

puts 'Deploy process started...'

# check if in master and nothing to commit, else - abort
check_git_status

# run git pull
ask_user "I'm going to run git pull, is it ok?"
`git pull`

# check status ok, else abort
check_git_status

# check pod validation status. if isn't ok - abort
verify_pod


# --increment version
# change the version in podspec_filename
actual_content = File.read(podspec_filename)
new_content = actual_content.gsub(/(^Pod::Spec(.|\s)*?s\.version.*?=.*?")(.*?)("(.|\s)*)/) { |str| $1 + new_pod_version + $4 }
File.open(podspec_filename, "w") {|file| file.puts new_content }
# commit all changes
`git add --all`
`git commit -m "Pod version changed to #{new_pod_version}"`

# --tag new version
# create tag according to version number
`git tag -a #{new_pod_version} -m "Pod version changed to #{new_pod_version}"`

# --push all the changes to master
# push master to origin master
puts "Pushing changes to origin..."
`git push origin master --tags`

# --publish repo changes to podspec repo
puts "Publishing pod to pod repo..."
pod_repo_push_log = `pod repo push Humanify #{podspec_filename} --allow-warnings`

# check pod repo push status. if errors - abort
check_pod_log_for_errors pod_repo_push_log

puts "Deploy of podspec #{podspec_filename} with version #{new_pod_version} finished successfully."
