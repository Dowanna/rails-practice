class HelloBatch
  def self.execute
    user = User.first
    user.name = 'updated again by batch!'
    user.save
  end
end