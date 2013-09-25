# GribRepoInterface is an abstract class which only defines what subclasses should implement.
module GribRepoInterfaces
  class GribRepoInterface
    def get_data_folder
      throw "Abstract method called"
    end
    def get_current_branch
      throw "Abstract method called"
    end
  end
end

%w{ git }.each do |lib|
  require File.expand_path("../#{lib}", __FILE__)
end