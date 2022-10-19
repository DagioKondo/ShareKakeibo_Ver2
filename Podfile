source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '14.5'
use_frameworks!

workspace 'Kakeibo'
project 'Kakeibo.xcodeproj'

def firebase_common
  pod 'Firebase/Storage'
  pod 'Firebase/Auth'
  pod 'Firebase/Firestore'
end

target 'Kakeibo' do

  project 'Kakeibo.xcodeproj'

  firebase_common

  pod 'IQKeyboardManagerSwift'
  pod 'ViewAnimator'
  pod 'SDWebImage'
  pod 'Charts'
  pod 'SegementSlide'
  pod 'Parchment'
  pod 'CropViewController'

end

target 'SKCore' do

  project 'Kakeibo.xcodeproj'

  firebase_common
end