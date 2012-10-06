require 'lib/grib_conf'
# GribRepoConf contains a GribData per each branch and a general GribData for all branches
# It is used to store both repository-based settings and branch-based settings
# GribRepoConf#get_conf returns the merged settings of a branch and its repo.
# GribRepoConf acts as a regular GribConf for the general repo settings.
class GribRepoConf < GribConf
  def initialize(file_or_filename)
    if file_or_filename.is_a?(String)
      @filename = file_or_filename
      file = File.open(@filename)
    elsif file_or_filename.is_a?(File)
      @filename = file_or_filename.path
      file = file_or_filename
    else
      throw InvalidArgument
    end
    data = YAML.load(file)
    @branches = {}
    (data["branches"] || {}).each do |branch_name, branch_data|
      @branches[branch_name] = GribConf.new(branch_data, branch_name, self)
    end
    # Init the general GribConf object according to the "general" key in the data
    super(data["general"], "General")
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
    file = File.new(@filename, "w")
    file.write(YAML.dump({"branches" => @branches, "general" => self}))
    file.close
  end
end