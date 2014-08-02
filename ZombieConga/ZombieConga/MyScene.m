//
//  MyScene.m
//  ZombieConga
//
//  Created by Marcelo de Aguiar Machado Júnior on 21/04/14.
//  Copyright (c) 2014 Marcelo de Aguiar Machado Júnior. All rights reserved.
//

#import "MyScene.h"
#import "GameOverScene.h"
@import AVFoundation;

#define ARC4RANDOM_MAX 0x100000000

static inline CGFloat ScalarRandomRange(CGFloat min, CGFloat max)
{
    return floorf(((double)arc4random() / ARC4RANDOM_MAX) * (max - min) + min);
}
                                                                   
static inline CGPoint CGPointAdd(const CGPoint a, const CGPoint b)
{
    return CGPointMake(a.x + b.x, a.y + b.y);
}

static inline CGPoint CGPointSubtract(const CGPoint a, const CGPoint b)
{
    return CGPointMake(a.x - b.x, a.y - b.y);
}

static inline CGPoint CGPointMultiplyScalar(const CGPoint a, const CGFloat b)
{
    return CGPointMake(a.x * b, a.y * b);
}
                                          
static inline CGFloat CGPointLength(const CGPoint a)
{
    // Pythagorean theorem - it says the length of the hypotenuse is equal to the square root of the sum of the squares of the two sides.
    return sqrtf(a.x * a.x + a.y * a.y);
}

static inline CGPoint CGPointNormalize(const CGPoint a)
{
    CGFloat length = CGPointLength(a);
    return CGPointMake(a.x / length, a.y / length);
}

static inline CGFloat CGPointToAngle(const CGPoint a)
{
    return atan2f(a.y, a.x);
}

static inline CGFloat ScalarSign(CGFloat a) {
    return a >= 0 ? 1 : -1;
}
// Returns shortest angle between two angles,
// between -M_PI and M_PI
static inline CGFloat ScalarShortestAngleBetween(const CGFloat a, const CGFloat b) {
    CGFloat difference = b - a;
    CGFloat angle = fmodf(difference, M_PI * 2);
    if (angle >= M_PI) {
        angle -= M_PI * 2;
    }
    else if (angle <= -M_PI) {
        angle += M_PI * 2;
    }
    return angle;
}

static const float ZOMBIE_MOVE_POINTS_PER_SEC = 120.0;
static const float ZOMBIE_ROTATE_RADIANS_PER_SEC = 4 * M_PI;
static const float CAT_MOVE_POINTS_PER_SEC = 120.0;
static const float BG_POINTS_PER_SEC = 50;

@implementation MyScene
{
    SKSpriteNode *_zombie;
    NSTimeInterval _lastUpdateTime;
    NSTimeInterval _dt;
    CGPoint _velocity;
    CGPoint _lastTouchLocation;
    SKAction *_zombieAnimation;
    SKAction *_catCollisionSound;
    SKAction *_enemyCollisionSound;
    BOOL _invincible;
    int _lives;
    BOOL _gameOver;
    AVAudioPlayer *_backgroundMusicPlayer;
    SKNode *_bgLayer;
}

-(id)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size]) {
        _bgLayer = [SKNode node];
        [self addChild:_bgLayer];
        
        self.backgroundColor = [SKColor whiteColor];
        
        _lives = 5;
        _gameOver = NO;
        
        [self playBackgroundMusic:@"bgMusic.mp3"];
        
        for (int i = 0; i < 2; i++) {
            SKSpriteNode * bg = [SKSpriteNode spriteNodeWithImageNamed:@"background"];
            bg.anchorPoint = CGPointZero;
            bg.position = CGPointMake(i * bg.size.width, 0);
            //bg.position = CGPointZero;
            bg.name = @"bg";
           // [self addChild:bg];
            [_bgLayer addChild:bg];
        }
 /*
        SKSpriteNode *bg = [SKSpriteNode spriteNodeWithImageNamed:@"background"];
        bg.position = CGPointMake(self.size.width/2, self.size.height/2);
        bg.anchorPoint = CGPointMake(0.5, 0.5);   // same as default
        
        [self addChild:bg];
        */
  ///      CGSize mySize = bg.size;
     /////   NSLog(@"Size: %@", NSStringFromCGSize(mySize));
        
        _zombie = [SKSpriteNode spriteNodeWithImageNamed:@"zombie1"];
        _zombie.position = CGPointMake(100, 100);
        //  [_zombie setScale:2.0];   // SKNode method
        
        ///[self addChild:_zombie];
        [_bgLayer addChild:_zombie];
        
        // 1
        NSMutableArray *textures = [NSMutableArray arrayWithCapacity:10];
        // 2
        for (int i = 1; i < 4; i++) {
            NSString *textureName = [NSString stringWithFormat:@"zombie%d", i];
            SKTexture *texture = [SKTexture textureWithImageNamed:textureName];
            [textures addObject:texture];
        }
        // 3
        for (int i = 4; i > 1; i--) {
            NSString *textureName = [NSString stringWithFormat:@"zombie%d", i];
            SKTexture *texture = [SKTexture textureWithImageNamed:textureName];
            [textures addObject:texture];
        }
        // 4
        _zombieAnimation = [SKAction animateWithTextures:textures timePerFrame:0.1];
        // 5
        //////[_zombie runAction: [SKAction repeatActionForever:_zombieAnimation]];
    
        // [self spawnEnemy];
        [self runAction:[SKAction repeatActionForever: [SKAction sequence:@[[SKAction performSelector:@selector(spawnEnemy) onTarget:self], [SKAction waitForDuration:2.0]]]]];
        
        [self runAction:[SKAction repeatActionForever: [SKAction sequence:@[[SKAction performSelector:@selector(spawnCat) onTarget:self],
                                                                            [SKAction waitForDuration:1.0]]]]];
        _catCollisionSound = [SKAction playSoundFileNamed:@"hitCat.wav" waitForCompletion:NO];
        _enemyCollisionSound = [SKAction playSoundFileNamed:@"hitCatLady.wav" waitForCompletion:NO];
    }
    return self;
}

- (void)startZombieAnimation {
    if (![_zombie actionForKey:@"animation"]) {
        [_zombie runAction: [SKAction repeatActionForever:_zombieAnimation] withKey:@"animation"];
    }
}

- (void)stopZombieAnimation {
    [_zombie removeActionForKey:@"animation"];
}
//// Gesture recognizer example
//// Uncomment this, and comment the touchesBegan/Moved/Ended methods to test
//- (void)didMoveToView:(SKView *)view
//{
//    UITapGestureRecognizer * tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
//    [self.view addGestureRecognizer:tapRecognizer];
//}

///- (void)handleTap:(UITapGestureRecognizer *)recognizer {
//    CGPoint touchLocation = [recognizer locationInView:self.view];
//    touchLocation = [self convertPointFromView:touchLocation];
//    [self moveZombieToward:touchLocation];
//}
////////

- (void)update:(CFTimeInterval)currentTime
{
    if (_lastUpdateTime) {
        _dt = currentTime - _lastUpdateTime;
    } else {
        _dt = 0;
    }
    _lastUpdateTime = currentTime;
 /////////   NSLog(@"%0.2f milliseconds since last update", _dt * 1000);
   // [self moveSprite:_zombie velocity:CGPointMake(ZOMBIE_MOVE_POINTS_PER_SEC, 0)];
/*
    CGPoint offset = CGPointSubtract(_lastTouchLocation, _zombie.position);
   float distance = CGPointLength(offset);
    
    if (distance < ZOMBIE_MOVE_POINTS_PER_SEC * _dt) {
        _zombie.position = _lastTouchLocation;
        _velocity = CGPointZero;
        [self stopZombieAnimation];
    } else {*/
        [self moveSprite:_zombie velocity:_velocity];
        [self boundsCheckPlayer];
        [self rotateSprite:_zombie toFace:_velocity rotateRadiansPerSec:ZOMBIE_ROTATE_RADIANS_PER_SEC];
  //  }
    
    [self moveTrain];
    [self moveBg];
    
    if (_lives <= 0 && !_gameOver) {
        _gameOver = YES;
        NSLog(@"You lose!");
        [_backgroundMusicPlayer stop];
        // 1
        SKScene * gameOverScene = [[GameOverScene alloc] initWithSize:self.size won:NO];
    ////    SKScene * gameOverScene = [[GameOverScene alloc] initWithSize:self.size];
        // 2
        SKTransition *reveal = [SKTransition flipHorizontalWithDuration:0.5];
        // 3
        [self.view presentScene:gameOverScene transition:reveal];
    }
    
   /// [self checkCollisions];
}

- (void)moveSprite:(SKSpriteNode *)sprite velocity:(CGPoint)velocity
{
    // 1
    CGPoint amountToMove = CGPointMultiplyScalar(velocity, _dt);
 /////////   NSLog(@"Amount to move: %@", NSStringFromCGPoint(amountToMove));
    // 2
    sprite.position = CGPointAdd(sprite.position, amountToMove);
}

- (void)moveZombieToward:(CGPoint)location
{
    [self startZombieAnimation];
    _lastTouchLocation = location;
    CGPoint offset = CGPointSubtract(location, _zombie.position);
    // Normalizing a vector
    CGPoint direction = CGPointNormalize(offset);
    _velocity = CGPointMultiplyScalar(direction, ZOMBIE_MOVE_POINTS_PER_SEC);
  
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInNode:_bgLayer];
    [self moveZombieToward:touchLocation];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInNode:_bgLayer];
    [self moveZombieToward:touchLocation];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInNode:_bgLayer];
    [self moveZombieToward:touchLocation];
}

- (void)boundsCheckPlayer {
    // 1
    CGPoint newPosition = _zombie.position;
    CGPoint newVelocity = _velocity;
    
    // 2
    CGPoint bottomLeft = [_bgLayer convertPoint:CGPointZero fromNode:self];
    CGPoint topRight = [_bgLayer convertPoint:CGPointMake(self.size.width,
                                       self.size.height) fromNode:self];
 ///   CGPoint bottomLeft = CGPointZero;
////    CGPoint topRight = CGPointMake(self.size.width, self.size.height);
    
    // 3
    if (newPosition.x <= bottomLeft.x) {
        newPosition.x = bottomLeft.x;
        newVelocity.x = -newVelocity.x;
    }
    if (newPosition.x >= topRight.x) {
        newPosition.x = topRight.x;
        newVelocity.x = -newVelocity.x;
    }
    if (newPosition.y <= bottomLeft.y) {
        newPosition.y = bottomLeft.y;
        newVelocity.y = -newVelocity.y;
    }
    if (newPosition.y >= topRight.y) {
        newPosition.y = topRight.y;
        newVelocity.y = -newVelocity.y; }
    // 4
    _zombie.position = newPosition;
    _velocity = newVelocity;
}

- (void)rotateSprite:(SKSpriteNode *)sprite toFace:(CGPoint)velocity rotateRadiansPerSec:(CGFloat)rotateRadiansPerSec
{
    float targetAngle = CGPointToAngle(velocity);
    float shortest = ScalarShortestAngleBetween(sprite.zRotation, targetAngle);
    float amtToRotate = rotateRadiansPerSec * _dt;
    
    if (ABS(shortest) < amtToRotate) {
        amtToRotate = ABS(shortest);
    }
    sprite.zRotation += ScalarSign(shortest) * amtToRotate;
}

- (void)spawnEnemy
{
    SKSpriteNode *enemy = [SKSpriteNode spriteNodeWithImageNamed:@"enemy"];
    enemy.name = @"enemy";
 //   enemy.position = CGPointMake( self.size.width + enemy.size.width/2,
 //                                ScalarRandomRange(enemy.size.height/2, self.size.height-enemy.size.height/2));
    CGPoint enemyScenePos = CGPointMake(self.size.width + enemy.size.width/2,
                                        ScalarRandomRange(enemy.size.height/2, self.size.height-enemy.size.height/2));
    enemy.position = [self convertPoint:enemyScenePos toNode:_bgLayer];
    
    ///[self addChild:enemy];
    
    [_bgLayer addChild:enemy];
    SKAction *actionMove = [SKAction moveByX:-self.size.width + enemy.size.width y:0 duration:2.0];
   /// SKAction *actionMove = [SKAction moveToX:-enemy.size.width/2 duration:2.0];
    SKAction *actionRemove = [SKAction removeFromParent];
    [enemy runAction:[SKAction sequence:@[actionMove, actionRemove]]];
    ////[enemy runAction:actionMove];
}
/*
{
    SKSpriteNode *enemy = [SKSpriteNode spriteNodeWithImageNamed:@"enemy"];
    enemy.position = CGPointMake(self.size.width + enemy.size.width/2, self.size.height/2);
    
    [self addChild:enemy];
    
    SKAction *actionMidMove = [SKAction moveByX:-self.size.width/2-enemy.size.width/2
                    y:-self.size.height/2+enemy.size.height/2
             duration:1.0];
    SKAction *actionMove = [SKAction moveByX:-self.size.width/2-enemy.size.width/2
                    y:self.size.height/2+enemy.size.height/2
                    duration:1.0];
    
    // 3
    SKAction *wait = [SKAction waitForDuration:1.25];
    SKAction *logMessage = [SKAction runBlock:^{
        NSLog(@"Reached bottom!");
    }];
    
 //   SKAction *reverseMid = [actionMidMove reversedAction];
//    SKAction *reverseMove = [actionMove reversedAction];
    
   // SKAction *sequence =
  //  [SKAction  sequence:@[actionMidMove, logMessage, wait, actionMove, reverseMove, logMessage, wait, reverseMid]];
    SKAction *sequence = [SKAction sequence: @[actionMidMove, logMessage, wait, actionMove]];
    sequence = [SKAction sequence:@[sequence,[sequence reversedAction]]];
    
    // 4
   // [enemy runAction:sequence];
    SKAction *repeat = [SKAction repeatActionForever:sequence]; [enemy runAction:repeat];
}
*/

- (void)spawnCat
{
    // 1
    SKSpriteNode *cat = [SKSpriteNode spriteNodeWithImageNamed:@"cat"];
    cat.name = @"cat";
  //  cat.position = CGPointMake( ScalarRandomRange(0, self.size.width), ScalarRandomRange(0, self.size.height));
  //  cat.xScale = 0;
  //  cat.yScale = 0;
    
    CGPoint catScenePos = CGPointMake(ScalarRandomRange(0, self.size.width), ScalarRandomRange(0, self.size.height));
    cat.position = [self convertPoint:catScenePos toNode:_bgLayer];
    cat.xScale = 0;
    cat.yScale = 0;
//    CGPoint topRight = [_bgLayer convertPoint:CGPointMake(self.size.width, self.size.height) fromNode:self];
    ///[self addChild:cat];
    
    [_bgLayer addChild:cat];
/*
    // 2
    SKAction *appear = [SKAction scaleTo:1.0 duration:0.5];
    SKAction *wait = [SKAction waitForDuration:10.0];
    SKAction *disappear = [SKAction scaleTo:0.0 duration:0.5];
    SKAction *removeFromParent = [SKAction removeFromParent];
    [cat runAction: [SKAction sequence:@[appear, wait, disappear, removeFromParent]]];
}
*/
    cat.zRotation = -M_PI / 16;
    
    SKAction *appear = [SKAction scaleTo:1.0 duration:0.5];
    SKAction *leftWiggle = [SKAction rotateByAngle:M_PI / 8 duration:0.5];
    SKAction *rightWiggle = [leftWiggle reversedAction];
    SKAction *fullWiggle = [SKAction sequence: @[leftWiggle, rightWiggle]];
  //  SKAction *wiggleWait = [SKAction repeatAction:fullWiggle count:10];
    
    //SKAction *wait = [SKAction waitForDuration:10.0];
    SKAction *scaleUp = [SKAction scaleBy:1.2 duration:0.25];
    SKAction *scaleDown = [scaleUp reversedAction];
    SKAction *fullScale = [SKAction sequence: @[scaleUp, scaleDown, scaleUp, scaleDown]];
    SKAction *group = [SKAction group:@[fullScale, fullWiggle]];
    SKAction *groupWait = [SKAction repeatAction:group count:10];
                           
    SKAction *disappear = [SKAction scaleTo:0.0 duration:0.5];
    SKAction *removeFromParent = [SKAction removeFromParent];
    
    [cat runAction:[SKAction sequence: @[appear, groupWait, disappear, removeFromParent]]];
}

- (void)checkCollisions
{
    [_bgLayer enumerateChildNodesWithName:@"cat"
                               usingBlock: ^(SKNode *node, BOOL *stop) {
 //   [self enumerateChildNodesWithName:@"cat"
   //                        usingBlock:^(SKNode *node, BOOL *stop){
        SKSpriteNode *cat = (SKSpriteNode *)node;
        if (CGRectIntersectsRect(cat.frame, _zombie.frame)) {
           //[cat removeFromParent];
          // [self runAction:[SKAction playSoundFileNamed:@"hitCat.wav" waitForCompletion:NO]];
            [self runAction:_catCollisionSound];
            cat.name = @"train";
            [cat removeAllActions];
            [cat setScale:1];
            cat.zRotation = 0;
            [cat runAction:[SKAction colorizeWithColor:[SKColor greenColor] colorBlendFactor:1.0 duration:0.2]];
        }
    }];
    
    if (_invincible) {
        return;
    }
    [_bgLayer enumerateChildNodesWithName:@"enemy"
                               usingBlock: ^(SKNode *node, BOOL *stop) {
  //  [self enumerateChildNodesWithName:@"enemy"
    //                       usingBlock:^(SKNode *node, BOOL *stop){
        SKSpriteNode *enemy = (SKSpriteNode *)node;
        CGRect smallerFrame = CGRectInset(enemy.frame, 20, 20);
        if (CGRectIntersectsRect(smallerFrame, _zombie.frame)) {
            [self runAction:_enemyCollisionSound];
            [self loseCats];
            _lives--;
            _invincible = YES;
            float blinkTimes = 10;
            float blinkDuration = 3.0;
            SKAction *blinkAction =
            [SKAction customActionWithDuration:blinkDuration
                                   actionBlock:
             ^(SKNode *node, CGFloat elapsedTime) {
                 float slice = blinkDuration / blinkTimes;
                 float remainder = fmodf(elapsedTime, slice);
                 node.hidden = remainder > slice / 2;
             }];
            SKAction *sequence = [SKAction sequence:@[blinkAction, [SKAction runBlock:^{
                _zombie.hidden = NO;
                _invincible = NO;
            }]]];
            [_zombie runAction:sequence];
        }
    }];
}

- (void)didEvaluateActions
{
    [self checkCollisions];
}

- (void)moveTrain
{
    __block int trainCount = 0;
    __block CGPoint targetPosition = _zombie.position;
    [_bgLayer enumerateChildNodesWithName:@"train"
                               usingBlock: ^(SKNode *node, BOOL *stop) {
    //[self enumerateChildNodesWithName:@"train"
                 //          usingBlock:^(SKNode *node, BOOL *stop){
                               trainCount++;
                               if (!node.hasActions) {
                                   float actionDuration = 0.3;
                                   CGPoint offset = CGPointSubtract(targetPosition, node.position);
                                   CGPoint direction = CGPointNormalize(offset);
                                   CGPoint amountToMovePerSec = CGPointMultiplyScalar(direction, CAT_MOVE_POINTS_PER_SEC);
                                   CGPoint amountToMove = CGPointMultiplyScalar(amountToMovePerSec, actionDuration);
                                   SKAction *moveAction = [SKAction moveByX:amountToMove.x y:amountToMove.y duration:actionDuration];
                                   [node runAction:moveAction];
                               }
                               targetPosition = node.position;
                           }];
    
    if (trainCount >= 10 && !_gameOver) {
        _gameOver = YES;
        NSLog(@"You win!");
        [_backgroundMusicPlayer stop];
        // 1
        SKScene * gameOverScene = [[GameOverScene alloc] initWithSize:self.size won:YES];
       /// SKScene * gameOverScene = [[GameOverScene alloc] initWithSize:self.size];
        // 2
        SKTransition *reveal = [SKTransition flipHorizontalWithDuration:0.5];
        // 3
        [self.view presentScene:gameOverScene transition:reveal];
    }
    
}

- (void)loseCats
{
    // 1
    __block int loseCount = 0;
    [_bgLayer enumerateChildNodesWithName:@"train"
                               usingBlock: ^(SKNode *node, BOOL *stop) {
    ///[self enumerateChildNodesWithName:@"train" usingBlock:
 //    ^(SKNode *node, BOOL *stop) {
         // 2
         CGPoint randomSpot = node.position;
         randomSpot.x += ScalarRandomRange(-100, 100);
         randomSpot.y += ScalarRandomRange(-100, 100);
         // 3
         node.name = @"";
         [node runAction:
            [SKAction sequence:@[
                [SKAction group:@[
                    [SKAction rotateByAngle:M_PI * 4 duration:1.0],
                    [SKAction moveTo:randomSpot duration:1.0],
                    [SKAction scaleTo:0 duration:1.0]
                ]],
            [SKAction removeFromParent]
          ]]];
         
         // 4
         loseCount++;
         if (loseCount >= 2) {
             *stop = YES;
         }
     }];
}

- (void)playBackgroundMusic:(NSString *)filename
{
    NSError *error;
    NSURL *backgroundMusicURL = [[NSBundle mainBundle] URLForResource:filename withExtension:nil];
    _backgroundMusicPlayer = [[AVAudioPlayer alloc]
                              initWithContentsOfURL:backgroundMusicURL error:&error];
    _backgroundMusicPlayer.numberOfLoops = -1;
    [_backgroundMusicPlayer prepareToPlay];
    [_backgroundMusicPlayer play];
}

- (void)moveBg
{
    CGPoint bgVelocity = CGPointMake(-BG_POINTS_PER_SEC, 0);
    CGPoint amtToMove = CGPointMultiplyScalar(bgVelocity, _dt);
    _bgLayer.position = CGPointAdd(_bgLayer.position, amtToMove);
    
    [_bgLayer enumerateChildNodesWithName:@"bg" usingBlock:
        ^(SKNode *node, BOOL *stop) {
            SKSpriteNode * bg = (SKSpriteNode *) node;
            CGPoint bgScreenPos = [_bgLayer convertPoint:bg.position toNode:self];
            if (bgScreenPos.x <= -bg.size.width) {
                 bg.position = CGPointMake(bg.position.x + bg.size.width*2, bg.position.y);
             }
    }];
    /*
    [self enumerateChildNodesWithName:@"bg" usingBlock: ^(SKNode *node, BOOL *stop) {
        SKSpriteNode * bg = (SKSpriteNode *) node;
        CGPoint bgVelocity = CGPointMake(-BG_POINTS_PER_SEC, 0);
        CGPoint amtToMove = CGPointMultiplyScalar(bgVelocity, _dt);
        bg.position = CGPointAdd(bg.position, amtToMove);
        
        if (bg.position.x <= -bg.size.width) {
            bg.position = CGPointMake(bg.position.x + bg.size.width*2, bg.position.y);
        }

    }];
*/
}

@end