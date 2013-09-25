require 'yaml'
# GribRepoConf contains a GribData per each branch and a general GribData for all branches
# It is used to store both repository-based settings and branch-based settings
# GribRepoConf#get_conf returns the merged settings of a branch and its repo.
# GribRepoConf acts as a regular GribConf for the general repo settings.
class GribRepoConf < GribConf

  attr_accessor :filename

  def initialize(filename = nil, name = "Repo", parent = nil)
    @filename = filename || "/dev/null"
    data = {}
    if File.exists?(@filename)
      File.open(@filename) do |file|
        data = YAML.load(file) || {}
      end
    else
      File.new(@filename, "w").close # touch
    end
    @branches = {}
    (data["branches"] || {}).each do |branch_name, branch_data|
      @branches[branch_name] = GribConf.new(branch_data, "branch-#{branch_name}", self)
    end
    # Init the general GribConf object according to the "general" key in the data
    super(data["general"] || {}, name, parent)
  end

  def for_branch(branch)
    (@branches[branch] ||= GribConf.new({}, branch, self))
  end

  def get_conf(branch)
    return self.merge(for_branch(branch))
  end

  def set(branch, setting, value, autosave = false)
    for_branch(branch)[setting] = value
    save_file if autosave
  end

  def save_file()
    File.open(@filename, "w") do |file|
      YAML.dump({"branches" => @branches, "general" => self}, file)
    end
  end
end