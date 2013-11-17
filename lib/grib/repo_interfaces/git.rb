module GribRepoInterfaces
  class Git < GribRepoInterfaces::GribRepoInterface
    def get_data_folder
      project_folder = git("rev-parse --show-toplevel")
      dot_git = File.join(project_folder, ".git")
      return dot_git if File.directory?(dot_git)
      dot_git_content = File.read(dot_git)
      dot_git_content.match(/^gitdir: (.+)$/).tap do |match_data|
        return match_data[1]
      end
      raise "Could not resolve .git directory "
    end

    def get_current_branch
      git("rev-parse --abbrev-ref HEAD")
    end

    def get_current_remote_branch
      head = git("symbolic-ref -q HEAD")
      remote_branch = git("for-each-ref --format='%(upstream:short)' #{head}")

      # Try to fallback to the default "origin/my_branch" if no upstream set:
      remote_branch = "origin/#{get_current_branch}" if remote_branch.empty?
      remote_branch = false unless git("show-ref #{remote_branch}")

      remote_branch
    end

    def assert_alignment
      # get current and remote branches:
      current = get_current_branch
      remote = get_current_remote_branch

      # Assert a remote exists:
      return "Current branch '#{current}' has no remote branch" unless remote

      # Assert both branches are aligned:
      aligned = (get_identifier(current) == get_identifier(remote))
      return "Current branch '#{current}' isn't aligned with remote '#{remote}'.\n\n\tTry running \"git push origin #{current}\"" unless aligned

      # All right:
      return :success
    end


    private

    def get_identifier(branch)
      git("rev-parse #{branch}")
    end

    def git(args)
      %x[git #{args}].chomp
    end
  end
end
