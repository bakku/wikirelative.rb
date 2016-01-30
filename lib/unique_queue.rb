# monkey patch array
class Array
  def unique_push(elem)
    self.push(elem) unless self.include?(elem)
  end
end
