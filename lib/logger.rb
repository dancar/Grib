require 'logger'
class GribLogger < Logger
  def error(*args)
    super(*args)
    throw "Error logged"
  end
end
def make_logger()
  logger = GribLogger.new(STDOUT)
  logger.formatter = proc do |severity, dt, progname, msg| "* #{severity == "ERROR" ? "ERROR - " : ""} #{msg}\n" end
  logger.level = Logger.const_get Logger.constants[Logger.constants.map{|c| c.to_s}.find_index((ENV["LOGGING"] || "INFO"))]
  logger
end
$LOG = make_logger()
