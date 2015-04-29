//
//  gameWin.m
//  StopEating
//
//  Created by peng tong on 4/28/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "gameWin.h"

@implementation gameWin

-(void)newGame
{
    CCScene* gameScene = [CCBReader loadAsScene:@"GameScene"];
    [[CCDirector sharedDirector] replaceScene:gameScene];
}

-(void)endGame
{
    CCScene* mainScene = [CCBReader loadAsScene:@"MainScene"];
    CCTransition* transition = [CCTransition transitionRevealWithDirection:CCTransitionDirectionRight duration:1.0];
    [[CCDirector sharedDirector] replaceScene:mainScene withTransition:transition];
}


@end
