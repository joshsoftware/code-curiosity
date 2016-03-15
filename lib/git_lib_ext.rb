module GitLibExt
  def commit_branch(sha)
    command('branch', ['--contains', sha]).sub('* ', '')
  end

  def commit_grep(message)
    command_lines('log', ['--grep', message, '--pretty="%H - %s"'])
  end

  def commits_by_file(file)
    command_lines('log', ['--pretty="%H - %s"', '--follow', file])
  end
end

module GitCommitExt
  def branch
    name = @base.lib.commit_branch(sha) rescue nil
    return name if name

    commit_grep(self.message)
  end
end

module GitBaseExt
  def commit_grep(message)
    result = lib.commit_grep(message).map do |log|
      log.split(" - ").collect{|s| s.sub('"', '')}
    end

    # Remove non ascii chars
    non_ascii_range = "^\u{0000}-\u{007F}"
    clean_message = message.delete!(non_ascii_range)
    log = result.find{|r| r[1].delete(non_ascii_range) == message }

    if log
      return lib.commit_branch(log[0]) rescue nil
    end
  end

  def file_commits_count(file)
    path = File.join(self.dir.path, file)
    lib.commits_by_file(path).count
  end
end

Git::Lib.send :include, GitLibExt
Git::Object::Commit.send :include, GitCommitExt
Git::Base.send :include, GitBaseExt
