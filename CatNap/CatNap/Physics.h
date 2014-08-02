//
//  Physics.h
//  CatNap
//
//  Created by Marcelo de Aguiar Machado Júnior on 29/06/14.
//  Copyright (c) 2014 Marcelo de Aguiar Machado Júnior. All rights reserved.
//

#ifndef CatNap_Physics_h
#define CatNap_Physics_h

typedef NS_OPTIONS(uint32_t, CNPhysicsCategory)
{
    CNPhysicsCategoryCat = 1 << 0, // 0001 = 1
    CNPhysicsCategoryBlock = 1 << 1, // 0010 = 2
    CNPhysicsCategoryBed = 1 << 2, // 0100 = 4
    CNPhysicsCategoryEdge = 1 << 3, // 1000 = 8
    CNPhysicsCategoryLabel = 1 << 4, // 10000 = 16
    CNPhysicsCategorySpring = 1 << 5, // 100000 = 32
    CNPhysicsCategoryHook = 1 << 6, // 1000000 = 64
    CNPhysicsCategorySeesaw = 1 << 7,
};

#endif
