# Triangle Project Code.

# Triangle analyzes the lengths of the sides of a triangle
# (represented by a, b and c) and returns the type of triangle.
#
# It returns:
#   :equilateral  if all sides are equal
#   :isosceles    if exactly 2 sides are equal
#   :scalene      if no sides are equal
#
# The tests for this method can be found in
#   about_triangle_project.rb
# and
#   about_triangle_project_2.rb
#
def triangle(a, b, c)
  if a <= 0 or b <= 0 or c <= 0 then
    raise TriangleError, "0 or negative side length"
  end
  
  if a >= b and a >= c then
    longest = a
  elsif b >= a and b >= c then
    longest = b
  else
    longest = c
  end

  if longest >= (a + b + c)/2.0 then
    raise TriangleError, "sides don't add up"
  end

  if a == b and b == c then
    return :equilateral
  elsif a == b or b == c or c == a then
    return :isosceles
  else
    return :scalene
  end
end

# Error class used in part 2.  No need to change this code.
class TriangleError < StandardError
end
