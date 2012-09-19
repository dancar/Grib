class GribConf < Hash
  attr_accessor :conf_name
  ValidParams = [
    "server",
    "target-groups",
    "target-people",
    "summary",
    "description",
    "description-file",
    "testing-done",
    "branch",
    "change-description",
    "revision-range",
    "submit-as",
    "username",
    "password",
    "parent",
    "tracking-branch",
    "repository-url",
    "diff-filename",
    "http-username",
    "http-password"
  ]
  ValidFlags = [
    "new",
    "reopen",
    "guess-summary",
    "guess-description",
    "disable-proxy",
    "diff-only",
  ]
  AllOptions = ValidParams + ValidFlags

  def self.from_yaml(yaml_path)
    return GribConf.new(yaml_path,YAML.load(File.new(@datafile_path, "r")))
  end

  def []=(k,v)
    unless AllOptions.include?(k)
      $LOG.warn("Invalid option: #{k} with value #{v} in grib conf: #{@conf_name}")
      return
    end
    if ValidFlags.include?(k) && !v.class.name.match(/(True|False)Class/)
      $LOG.warn("Invalud boolean value: #{v} for flag: #{k} in configuration: #{@conf_name}. using #{!!v} instead")
      v = !!v
    end
    super(k,v)
  end

  def initialize(conf_name, gribdata)
    @conf_name = conf_name
    gribdata.each do |key,value|
      self[key] = value
    end
  end
end