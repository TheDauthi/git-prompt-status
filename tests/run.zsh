source ./helpers.zsh
# test_status fixtures/intel-analysis-questionable.test;  
for file in fixtures/*; do
  test_status $file
done
