//
//  MainScene.m
//  StopEating
//
//  Created by peng tong on 3/15/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "MainScene.h"

@implementation MainScene

-(void) playButtonPressed
{
	CCScene* scene = [CCBReader loadAsScene:@"GameScene"];
	CCTransition* transition = [CCTransition transitionMoveInWithDirection:CCTransitionDirectionLeft duration:1.0];
	[[CCDirector sharedDirector] presentScene:scene withTransition:transition];
}

@end
