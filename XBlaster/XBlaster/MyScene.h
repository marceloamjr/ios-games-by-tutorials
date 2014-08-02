//
//  MyScene.h
//  XBlaster
//

//  Copyright (c) 2014 Marcelo de Aguiar Machado Júnior. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

typedef enum : int {
    GameRunning      = 0,
    GameOver         = 1,
} GameState;

@interface MyScene : SKScene <SKPhysicsContactDelegate>

@property (nonatomic, strong) SKNode *playerLayerNode;
@property (nonatomic, strong) SKNode *hudLayerNode;
@property (nonatomic, strong) SKNode *bulletLayerNode;
@property (nonatomic, strong) SKNode *enemyLayerNode;

- (void)increaseScoreBy:(float)increment;

@end
