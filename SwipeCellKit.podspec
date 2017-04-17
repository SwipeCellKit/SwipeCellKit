Pod::Spec.new do |s|
   s.name = 'SwipeCellKit'
   s.version = '1.8.0'
   s.license = 'MIT'

   s.summary = 'Swipeable UITableViewCell based on the stock Mail.app, implemented in Swift.'
   s.homepage = 'https://github.com/jerkoch/SwipeCellKit'
   s.documentation_url = 'http://www.jerkoch.com/SwipeCellKit/'
   s.social_media_url = 'https://twitter.com/jerkoch'
   s.author = 'Jeremy Koch'

   s.source = { :git => 'https://github.com/jerkoch/SwipeCellKit.git', :tag => s.version }
   s.source_files = 'Source/*.swift'

   s.ios.deployment_target = '9.0'
end