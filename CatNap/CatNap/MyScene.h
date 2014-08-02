//
//  MyScene.h
//  CatNap
//

//  Copyright (c) 2014 Marcelo de Aguiar Machado Júnior. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@protocol ImageCaptureDelegate
- (void)requestImagePicker;
@end

@interface MyScene : SKScene

@property (nonatomic, assign)

id <ImageCaptureDelegate> delegate;

-(void)setPhotoTexture:(SKTexture *)texture;

@end
