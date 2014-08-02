//
//  PlayerShip.m
//  XBlaster
//
//  Created by Marcelo de Aguiar Machado Júnior on 05/05/14.
//  Copyright (c) 2014 Marcelo de Aguiar Machado Júnior. All rights reserved.
//

#import "PlayerShip.h"

@implementation PlayerShip

- (instancetype)initWithPosition:(CGPoint)position
{
    if (self = [super initWithPosition:position]) {
        self.name = @"shipSprite";
    }
    return self;
}

+ (SKTexture *)generateTexture
{
    // 1
    static SKTexture *texture = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 2
        SKLabelNode *mainShip =
        [SKLabelNode labelNodeWithFontNamed:@"Arial"];
        mainShip.name = @"mainship"; mainShip.fontSize = 20.0f;
        mainShip.fontColor = [SKColor whiteColor];
        mainShip.text = @"▲";
        // 3
        SKLabelNode *wings =
        [SKLabelNode labelNodeWithFontNamed:@"Arial"];
        wings.name = @"wings";
        wings.fontSize = 20.0f;
        wings.text = @"< >";
        wings.fontColor = [SKColor whiteColor];
        wings.position = CGPointMake(0, 7);
        // 4
        wings.zRotation = DegreesToRadians(180);
        [mainShip addChild:wings];
        // 5
        SKView *textureView = [SKView new];
        texture = [textureView textureFromNode:mainShip];
        texture.filteringMode = SKTextureFilteringNearest;
    });
    return texture;
}

@end
