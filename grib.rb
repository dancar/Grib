#!/usr/bin/env ruby
# Grib - Git Reviewboard script
require 'lib/grib_conf'
require 'lib/grib_repo_conf'
require 'lib/logger'
class Grib
  opts.parse!(ARGV)
  print("[grib.rb:31] commands:_\n\t"); pp(commands) # commands output

#   def initialize(args)
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



# Grib.new(ARGV).run()