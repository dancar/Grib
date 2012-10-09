require 'lib/repo_interfaces/grib_repo_interface'
module GribRepoInterfaces
  class Git < GribRepoInterfaces::GribRepoInterface
    def get_data_folder
      File.join(%x[git rev-parse --show-toplevel].chomp , ".git")
    end
    def get_current_branch
       %x[git symbolic-ref -q HEAD].sub(/^refs\/heads\//,"").chomp
    end
  end
end