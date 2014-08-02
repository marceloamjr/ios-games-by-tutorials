//
//  EnemyA.h
//  XBlaster
//
//  Created by Marcelo de Aguiar Machado Júnior on 05/05/14.
//  Copyright (c) 2014 Marcelo de Aguiar Machado Júnior. All rights reserved.
//

#import "Entity.h"

@class AISteering;

@interface EnemyA : Entity {
    int         _score;
    int         _damageTakenPerShot;
    NSString    *_healthMeterText;
}

@property (strong,nonatomic) AISteering *aiSteering;

@end
