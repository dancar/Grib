#!/usr/bin/env ruby
# Grib - Git Reviewboard script
$:.unshift File.dirname(__FILE__)
require 'lib/grib_conf'
require 'lib/grib_repo_conf'
require 'lib/grib_command_conf'
require 'lib/logger'
require 'lib/repo_interfaces/git'
require 'shellwords'

class Grib
  # Constants:
  VERSION = "2.0"
  USER_CONF_FILE = ".grib" # Will be concatenated to the HOME environment variable
  REPO_CONF_FILE = "gribdata.yml" # Will reside in the repository folder
  REPO_INTERFACES = {
    "git" => GribRepoInterfaces::Git,
    # "tests" = GribRepoInterface::TestsRepoInterface
    # TODO: add Mercurial
  }
  PR_COMMAND = "post-review"

  def initialize()
    $LOG = make_logger()
    $LOG.info "Welcome to Grib #{VERSION}"
    @repo_interface = REPO_INTERFACES[ENV["REPO"] || "git"].new
    Signal.trap("INT") {exit} # for reading a single character
  end

  def run()

    conf = obtain_configurations()
    conf["branch"] = @branch
    # Generate and run command:
    cmd = generate_pr_command(conf)
    @repo_conf.save_file
    if conf["dry"]
      $LOG.info cmd
      exit 0
    elsif conf["info"]
      print_info(conf)
      exit 0
    elsif conf["full-info"]
      print_info(conf, true)
      exit 0
    end

    $LOG.debug "command: \n\t'#{cmd}'"
    pr_output = %x[#{cmd}]

    # Process output:
    review_number = pr_output.match(/ #([0-9]+) /).tap{|r|
      unless r
        $LOG.error <<-END
  Could not capture review number, something must have gone wrong.
  ---post-review output:-----------------------------------------
  #{pr_output}
  ---------------------------------------------------------------
  Changes will not be saved.
  END
        exit -1
      end
    }[1]
    $LOG.debug "post-review output: \n#{"-"*64}\n#{pr_output}#{"-"*64}"
    $LOG.info "Review number : ##{review_number}"
    $LOG.info "Browser should now be opened." if conf["open"]
    @branch_conf["review-request-id"] = review_number
    @repo_conf.save_file
    $LOG.info("Changes saved to #{@repo_conf.filename}.") if @conf_changed

  end

  def obtain_configurations()
    @user_conf = get_user_conf()
    @branch = get_current_branch()
    @repo_conf = get_repo_conf(@user_conf)
    @branch_conf = @repo_conf.for_branch(@branch)
    $LOG.debug @branch_conf
    @conf_changed = false
    @command_line_conf = GribCommandConf.new(ARGV, "Command-Line Conf", @branch_conf) do |new_option, value|
      save_new_option(new_option,value)
    end
    $LOG.debug @commannd_line_conf
    @command_line_conf
  end

  def save_new_option(new_option, value)
    return if @branch_conf[new_option] == value # No need to save command-line argument if already saved
    print %Q[
    A new option have been specified:
      \t#{new_option} = "#{value}"
      Would you like to save this option as default for future invocations?
      \t(b) Yes, save as default for branch '#{@branch}'
      \t(r) Yes, save as default for all branches under the current repository
      \t(n) No, do not save this option
      Your choice: ].gsub(/^ */,"")
    user_ans = read_char()
    while not user_ans.match(/[brn]/)
      puts "Please type either 'b', 'r' or 'n'"
      user_ans = read_char()
    end

    case user_ans
      when "b" then @branch_conf[new_option] = value
      when "r" then @repo_conf[new_option] = value
    end
    puts user_ans
    @conf_changed = true if user_ans.match(/[br]/)
  end

  def generate_pr_command(conf)
    args = []
    args << PR_COMMAND
    GribConf::VALID_OPTIONS.each do |option|
      args << "--#{option}=#{Shellwords.escape(conf[option])}" unless conf[option].nil?
    end
    GribConf::VALID_FLAGS.each do |option|
      args << "--#{option}" if conf[option]
    end
    return args.join(" ")
  end

  def get_current_branch()
    branch = @repo_interface.get_current_branch
    $LOG.info "Current branch: #{branch}"
    return branch
  end

  def get_user_conf()
    filename = File.join(ENV["HOME"], USER_CONF_FILE)
    if File.exists?(filename)
      $LOG.debug "Using user configuration file: #{filename}"
      ans = GribConf.new(filename, "User")
      $LOG.debug ans
      return ans
    else
      $LOG.debug "No user configuration file found in #{filename}"
      return GribConf.new({}, "Empty User")
    end
  end

  def get_repo_conf(parent)
    repo_data_folder = @repo_interface.get_data_folder()
    filename = File.join repo_data_folder, REPO_CONF_FILE
    $LOG.debug "Repository configuration file: #{filename}"
    ans = GribRepoConf.new(filename, "Repo", parent)
    $LOG.debug ans
    ans
  end

  def print_info(conf, show_nils = false)
    $LOG.info "#{show_nils ? "Full " : ""}Configuration dump:"
    GribConf::ALL_OPTIONS.each do |o|
      v = conf[o]
      $LOG.info "\t#{o} = #{v}" if !v.nil? or show_nils
    end

  end

  def read_char()
    # magic from http://stackoverflow.com/questions/174933/how-to-get-a-single-character-without-pressing-enter
    begin
      system("stty raw -echo")
      str = STDIN.getc
    ensure
      system("stty -raw echo")
    end
    exit(-1) if str == 3 or str == 26
    return str.chr
  end
end

Grib.new().run()