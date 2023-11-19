=begin
g.log   # returns a Git::Log object, which is an Enumerator of Git::Commit objects
g.log(200)
g.log.since('2 weeks ago')
g.log.between('v2.5', 'v2.6')
g.log.each {|l| puts l.sha }
g.gblob('v2.5:Makefile').log.since('2 weeks ago')

g.object('HEAD^').to_s  # git show / git rev-parse
g.object('HEAD^').contents
g.object('v2.5:Makefile').size
g.object('v2.5:Makefile').sha

g.gtree(treeish)
g.gblob(treeish)
g.gcommit(treeish)


commit = g.gcommit('1cc8667014381')

commit.gtree
commit.parent.sha
commit.parents.size
commit.author.name
commit.author.email
commit.author.date.strftime("%m-%d-%y")
commit.committer.name
commit.date.strftime("%m-%d-%y")
commit.message

tree = g.gtree("HEAD^{tree}")

tree.blobs
tree.subtrees
tree.children # blobs and subtrees

g.revparse('v2.5:Makefile')

g.branches # returns Git::Branch objects
g.branches.local
g.current_branch
g.branches.remote
g.branches[:master].gcommit
g.branches['origin/master'].gcommit

g.grep('hello')  # implies HEAD
g.blob('v2.5:Makefile').grep('hello')
g.tag('v2.5').grep('hello', 'docs/')
g.describe()
g.describe('0djf2aa')
g.describe('HEAD', {:all => true, :tags => true})

g.diff(commit1, commit2).size
g.diff(commit1, commit2).stats
g.diff(commit1, commit2).name_status
g.gtree('v2.5').diff('v2.6').insertions
g.diff('gitsearch1', 'v2.5').path('lib/')
g.diff('gitsearch1', @git.gtree('v2.5'))
g.diff('gitsearch1', 'v2.5').path('docs/').patch
g.gtree('v2.5').diff('v2.6').patch

g.gtree('v2.5').diff('v2.6').each do |file_diff|
  puts file_diff.path
  puts file_diff.patch
  puts file_diff.blob(:src).contents
end

g.worktrees # returns Git::Worktree objects
g.worktrees.count
g.worktrees.each do |worktree|
  worktree.dir
  worktree.gcommit
  worktree.to_s
end

g.config('user.name')  # returns 'Scott Chacon'
g.config # returns whole config hash

# Configuration can be set when cloning using the :config option.
# This option can be an single configuration String or an Array
# if multiple config items need to be set.
#
g = Git.clone(
  git_uri, destination_path,
  :config => [
    'core.sshCommand=ssh -i /home/user/.ssh/id_rsa',
    'submodule.recurse=true'
  ]
)

g.tags # returns array of Git::Tag objects

g.show()
g.show('HEAD')
g.show('v2.8', 'README.md')

Git.ls_remote('https://github.com/ruby-git/ruby-git.git') # returns a hash containing the available references of the repo.
Git.ls_remote('/path/to/local/repo')
Git.ls_remote() # same as Git.ls_remote('.')

Git.default_branch('https://github.com/ruby-git/ruby-git') #=> 'master'

=end

=begin
parts[1].map{ |x| 
  p x.class
  p x 
}
=end