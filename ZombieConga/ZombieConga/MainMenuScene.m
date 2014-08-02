//
//  MainMenuScene.m
//  ZombieConga
//
//  Created by Marcelo de Aguiar Machado Júnior on 29/04/14.
//  Copyright (c) 2014 Marcelo de Aguiar Machado Júnior. All rights reserved.
//

#import "MainMenuScene.h"
#import "MyScene.h"

@implementation MainMenuScene

- (id)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size]) {
        SKSpriteNode *bg;
        bg = [SKSpriteNode spriteNodeWithImageNamed:@"MainMenu.png"];
        bg.position = CGPointMake(self.size.width/2, self.size.height/2);
        [self addChild:bg];
        
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    SKTransition *reveal = [SKTransition doorwayWithDuration:3.0];
    SKScene * myScene = [[MyScene alloc] initWithSize:self.size];
    [self.view presentScene:myScene transition: reveal];
}

@end
