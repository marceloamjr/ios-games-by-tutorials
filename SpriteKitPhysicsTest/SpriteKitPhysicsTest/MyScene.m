//
//  MyScene.m
//  SpriteKitPhysicsTest
//
//  Created by Marcelo de Aguiar Machado Júnior on 07/05/14.
//  Copyright (c) 2014 Marcelo de Aguiar Machado Júnior. All rights reserved.
//

#import "MyScene.h"

#define ARC4RANDOM_MAX 0x100000000

static inline CGFloat ScalarRandomRange(CGFloat min, CGFloat max)
{
    return floorf(((double)arc4random() / ARC4RANDOM_MAX) * (max - min) + min);
}

@implementation MyScene
{
    SKSpriteNode *_square;
    SKSpriteNode *_circle;
    SKSpriteNode *_triangle;
    SKSpriteNode *_octagon;
    
    NSTimeInterval _dt;
    NSTimeInterval _lastUpdateTime;
    CGVector _windForce;
    BOOL _blowing;
    NSTimeInterval _timeUntilSwitchWindDirection;
}

-(instancetype)initWithSize:(CGSize)size
{
    if(self = [super initWithSize:size]) {
       // _square = [SKSpriteNode spriteNodeWithImageNamed:@"square"];
       // _square.position = CGPointMake(self.size.width * 0.25, self.size.height * 0.50);
       // [self addChild:_square];
        
        _octagon = [SKSpriteNode spriteNodeWithImageNamed:@"octagon"];
        _octagon.position = CGPointMake(self.size.width * 0.25, self.size.height * 0.50);
        [self addChild:_octagon];
        
        _circle = [SKSpriteNode spriteNodeWithImageNamed:@"circle"];
        _circle.position = CGPointMake(self.size.width * 0.50, self.size.height * 0.50);
        _circle.physicsBody.dynamic = NO;
        [self addChild:_circle];
        
        _triangle = [SKSpriteNode spriteNodeWithImageNamed:@"triangle"];
        _triangle.position = CGPointMake(self.size.width * 0.75, self.size.height * 0.50);
        [self addChild:_triangle];
        
        _circle.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:_circle.size.width/2];
  //      _square.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:_square.size];
        
        CGMutablePathRef octagonPath = CGPathCreateMutable();
        CGPathMoveToPoint(octagonPath, nil, -_octagon.size.width/4, -_octagon.size.height/2);
        
        CGPathAddLineToPoint(octagonPath, nil, _octagon.size.width/4, -_octagon.size.height/2);
        CGPathAddLineToPoint(octagonPath, nil, _octagon.size.width/2, -_octagon.size.height/4);
        CGPathAddLineToPoint(octagonPath, nil, _octagon.size.width/2, _octagon.size.height/4);
        CGPathAddLineToPoint(octagonPath, nil, _octagon.size.width/4, _octagon.size.height/2);
        CGPathAddLineToPoint(octagonPath, nil, -_octagon.size.width/4, _octagon.size.height/2);
        CGPathAddLineToPoint(octagonPath, nil, -_octagon.size.width/2, _octagon.size.height/4);
        CGPathAddLineToPoint(octagonPath, nil, -_octagon.size.width/2, -_octagon.size.height/4);
        CGPathAddLineToPoint(octagonPath, nil, -_octagon.size.width/4, -_octagon.size.height/2);
        
        _octagon.physicsBody = [SKPhysicsBody bodyWithPolygonFromPath:octagonPath];
        CGPathRelease(octagonPath);
        
        self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
        
        //1
        CGMutablePathRef trianglePath = CGPathCreateMutable();
        
        //2
        CGPathMoveToPoint(trianglePath, nil, -_triangle.size.width/2, -_triangle.size.height/2);
        
        //3
        CGPathAddLineToPoint(trianglePath, nil, _triangle.size.width/2, -_triangle.size.height/2);
        CGPathAddLineToPoint(trianglePath, nil, 0, _triangle.size.height/2);
        CGPathAddLineToPoint(trianglePath, nil, -_triangle.size.width/2, -_triangle.size.height/2);
        
        //4
        _triangle.physicsBody = [SKPhysicsBody bodyWithPolygonFromPath:trianglePath];
        
        //5
        CGPathRelease(trianglePath);
        
        [self runAction: [SKAction repeatAction:
                          [SKAction sequence: @[[SKAction performSelector:@selector(spawnSand)
                                                onTarget:self], [SKAction waitForDuration:0.02]]]
                                          count:100]];
    }
    
    return self;
}

- (void)spawnSand
{
    //create a small ball body
    SKSpriteNode *sand = [SKSpriteNode spriteNodeWithImageNamed:@"sand"];
    sand.position = CGPointMake( (float)(arc4random()%(int)self.size.width), self.size.height - sand.size.height);
    sand.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:sand.size.width/2];
    sand.name = @"sand";
    [self addChild:sand];
    sand.physicsBody.restitution = 1.0;
    sand.physicsBody.density = 20.0;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (SKSpriteNode *node in self.children) {
        if ([node.name isEqualToString:@"sand"])
            [node.physicsBody applyImpulse: CGVectorMake(0, arc4random()%50)];
    }
  
    SKAction *shake = [SKAction moveByX:0 y:10 duration:0.05];
    [self runAction: [SKAction repeatAction:
                      [SKAction sequence:@[shake, [shake reversedAction]]]
                                      count:5]];
    
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInNode:self];
    [_circle removeAllActions];
    [_circle runAction:[SKAction moveTo:touchLocation duration:0.5]];
}

- (void)update:(NSTimeInterval)currentTime
{
    // 1
    if (_lastUpdateTime) {
        _dt = currentTime - _lastUpdateTime;
    } else {
        _dt = 0;
    }
    _lastUpdateTime = currentTime;
    // 2
    _timeUntilSwitchWindDirection -= _dt;
    
    if (_timeUntilSwitchWindDirection <= 0) {
        _timeUntilSwitchWindDirection = ScalarRandomRange(1, 5);
       // _windForce = CGVectorMake(0, 0); // 3 – Replace me!
        _windForce = CGVectorMake(ScalarRandomRange(-50, 50), 0);
        NSLog(@"Wind force: %0.2f, %0.2f", _windForce.dx, _windForce.dy);
    }
    // 4 – Do something here!
    for (SKSpriteNode *node in self.children) {
        [node.physicsBody applyForce:_windForce];
    }

}

@end