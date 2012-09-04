#!/usr/bin/env ruby
# Grib - Git Reviewboard script
# Creates / updates reviews according to the current git branch
# Usage: just run it.
# If this is the first time a review is created for this branch, Grib will ask Reviewboard to create a new review, and will save this review's number
# If the current branch has already been reviewed, Grib will ask Reviewboard to add a diff to the existing review.
# You can run grib with the argument --new to force a new review to be created
# Grib stores its data and configuration in a file named "gribdata.yml" under the .git directory.
# In this file you may also define default Reviewboard's target people/groups, whether to automatically open the browser or not, and other Reviewboard command options.
# Example gribdata.yml file:
#
# ---
# branches:
#   dan-17357-fix-infection-time-sorting: 348
#   dan-123r5-shecker-kolsheu: 100
# options:
#   open_browser: true
#   target_people:
#     - uriel
#     - ido
#   target_groups: []
#   misc: '--debug'

# TODO:
# fix description overriding in diff reviews
# fix auto summary
require "yaml"
require 'logger'

logger = Logger.new(STDOUT)
logger.formatter = proc do |severity, dt, progname, msg| "* #{severity == "ERROR" ? "ERROR - " : ""} #{msg}\n" end
logger.level = Logger::INFO

args = ARGV.join " "
logger.debug "args: #{args}"

branch = %x[git symbolic-ref -q HEAD].sub(/^refs\/heads\//,"").chomp
logger.info "Branch: #{branch}"

datafile_path = File.join(%x[git rev-parse --show-toplevel].chomp , ".git", "gribdata.yml")
logger.debug "datafile_path: #{datafile_path}";

data = File.exist?(datafile_path) ? YAML.load(File.new(datafile_path, "r")) : {}
logger.debug "data: #{data}";

r = !args.match(/--new/) && (data["branches"] ||= {})[branch]
logger.info "review: #{r || "new review"}"

options = (data["options"] ||= {})
logger.debug "options: #{options}";

open_browser = (options["open_browser"] ||= true)
logger.debug "open_browser: #{open_browser}"

target_people = (options["target_people"]||=[]).join ","
logger.debug "target_people: #{target_people}"

target_groups = (options["target_groups"]||=[]).join ","
logger.debug "target_groups: #{target_groups}"

misc = (options["misc"] ||= "")
logger.debug "misc: #{misc}"

revision_or_guess = r ? "--diff-only -r#{r}" : "--guess-fields"
logger.debug

cmd = %Q[post-review #{revision_or_guess} --target-people="#{target_people}" --target-groups="#{target_groups}" --branch="#{branch}" #{open_browser ? "-o" : ""} #{misc} #{args} ]
logger.info "running: #{cmd}"

response = %x[#{cmd}]
logger.info "Post-review response:\n #{response}"

logger.info "Browser should be opened..." if open_browser

new_r = response.match(/ #([0-9]+) /).tap {|md|
  unless md
    logger.error  "ERROR - Could not find review number"
    exit
  end
}[1].to_i

logger.info "new_r: #{new_r}"

data["branches"][branch] = new_r

File.new(datafile_path, "w").write(YAML.dump(data))
logger.debug "done."
