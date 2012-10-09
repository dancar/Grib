#!/usr/bin/env ruby
# Grib - Git Reviewboard script
require 'lib/grib_conf'
require 'lib/grib_repo_conf'
require 'lib/grib_command_conf'
require 'lib/logger'
require 'lib/repo_interfaces/git'

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
    # TODO: add support for --new, --info

    # Obtain configurations:
    user_conf = get_user_conf()
    branch = get_current_branch()
    repo_conf = get_repo_conf(user_conf)
    branch_conf = repo_conf.for_branch(branch)
    $LOG.debug branch_conf
    command_line_conf = GribCommandConf.new(ARGV, "Command-Line Conf", branch_conf) do |new_option, value|
      next if branch_conf[new_option] == value # No need to save command-line argument if already saved
      puts "\nNew option:\n\t#{new_option} = #{value}"
      puts "Save new option?\n\t(b) for branch '#{branch}'\n\t(r) for current repository\n\t(n) Do not save"
      user_ans = read_char()
      while not user_ans.match(/[brn]/)
        puts "Please type either 'b', 'r' or 'n'"
        user_ans = read_char()
      end

      case user_ans
        when "b" then branch_conf[new_option] = value
        when "r" then repo_conf[new_option] = value
      end
    end
    conf = command_line_conf
    $LOG.debug conf
    # Generate and run command:
    cmd = generate_pr_command(conf)
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
    branch_conf["review-request-id"] = review_number
    repo_conf.save_file

  end

  def generate_pr_command(conf)
    args = []
    args << PR_COMMAND
    GribConf::VALID_OPTIONS.each do |option|
      args << "--#{option}=#{conf[option]}" unless conf[option].nil?
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

#     @cmds = ["post-review"]
#     @logger = make_logger()
#     @args = args.dup()
#     @gribdata = obtain_gribdata()
#     parse_args()
#   end

#   def run()
#     @branch_data["r"] = run_command()
#     save_gribdata()
#     logger.debug "done."
#   end

# private
#   def add_arg(name, value=nil)
#     new_arg = "--#{name}"
#     new_agg << '="#{value}"' unless value.nil?
#     add_raw_arg new_arg
#   end

#   def add_raw_arg(raw_arg)
#     @cmds << raw_arg
#     @logger.debug "added argument: #{raw_arg}"
#   end

#   def get_long_argument_value(arg_name)
#     match = args.join(" ").match(/--#{arg_name}[= ]([\"\']?)([-_a-zA-Z0-9,]+)\1/)
#     return match ? match [2] : nil
#   end

#   def obtain_gribdata()
#     @datafile_path = File.join(%x[git rev-parse --show-toplevel].chomp , ".git", "gribdata.yml")
#     @logger.info "Gribdata file: #{@datafile_path}"
#     @gribdata = File.exist?(@datafile_path) ? YAML.load(File.new(@datafile_path, "r")) : {}
#     @logger.debug "gribdata: #{@gribdata}";
#     @gribdata
#   end

#   def parse_args()
#     # Force new
#     force_new = @args.delete("--new")
#     @logger.debug "force_new: #{force_new}"

#     # Branch:
#     branch = %x[git symbolic-ref -q HEAD].sub(/^refs\/heads\//,"").chomp
#     add_arg "branch", branch

#     # Branch data
#     branch_data = ((@gribdata["branches"] ||= {})[branch] ||= {})
#     @logger.debug "branch data: #{branch_data}"

#     # r
#     r = !force_new && branch_data["r"]
#     @logger.info "Review #: #{r || "new review"}"

#     revision_or_guess = r ? "--diff-only -r#{r}" : "--guess-fields"
#     add_raw_arg revision_or_guess

#     # Parent
#     branch_data["parent"] = get_long_argument_value("parent") || branch_data["parent"]
#     add_arg("parent", branch_data["parent"])

#     # Options
#     options = (@gribdata["options"] ||= {})
#     logger.debug "options: #{options}";

#     # open_browser
#     open_browser = (options["open_browser"] ||= true)
#     add_raw_arg "-o" if open_browser

#     # Targets:
#     target_people = (options["target_people"]||=[]).join ","
#     target_groups = (options["target_groups"]||=[]).join ","
#     add_arg("target_people", target_people) if target_people
#     add_arg("target_groups", target_groups) if target_groups

#     # Misc options
#     misc = (options["misc"] ||= "")
#     add_raw_arg(misc)
#   end

#   def run_command()
#     cmd = @cmds.join (" ")
#     logger.info "running command:\n\t\"#{cmd}\""

#     response = %x[#{cmd}]
#     logger.info "Post-review response:\n #{response}"
#     logger.info "Browser should be opened..." if open_browser

#     new_r = response.match(/ #([0-9]+) /).tap {|md|
#       unless md
#         logger.error  "ERROR - Could not find review number"
#         exit
#       end
#     }[1]
#     logger.info "Review number: #{new_r}"
#     new_r
#   end

#   def save_gribdata()
#     @logger.debug "Saving to file #{@gribdata}..."
#     File.new(@datafile_path, "w").write(YAML.dump(@gribdata))
#     @logger.deug "File saved successfully."
#   end
end

Grib.new().run()
