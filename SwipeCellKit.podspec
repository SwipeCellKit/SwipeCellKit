Pod::Spec.new do |s|
   s.name = 'SwipeCellKit'
   s.version = '1.0.0'
   s.license = 'MIT'

   s.summary = 'A swipeable UITableViewCell comparable to the stock iOS Mail.app'
   s.homepage = 'https://github.com/jerkoch/SwipeCellKit'
   s.social_media_url = 'https://twitter.com/jerkoch'
   s.author = 'Jeremy Koch'

   s.source = { :git => 'https://github.com/jerkoch/CellSwipeKit.git', :tag => s.version }
   s.source_files = 'Source/*.swift'

   s.ios.deployment_target = '10.0'
end