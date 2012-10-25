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
  logger.level = Logger.const_get(ENV["LOGGING"].upcase.to_sym) rescue Logger::INFO
  logger
end
$LOG = make_logger()
