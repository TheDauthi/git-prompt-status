source ./helpers.zsh

for file in fixtures/*; do
  test_status $file
done
