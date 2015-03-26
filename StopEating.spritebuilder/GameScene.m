//
//  GameScene.m
//  LearnSpriteBuilder
//
//  Created by Steffen Itterheim on 25/06/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "GameScene.h"
#import <UIKit/UIKit.h>

@implementation GameScene
{
    __weak CCNode* _levelNode;
    __weak CCPhysicsNode* _physicsNode;
    __weak CCNode* _playerNode;
    __weak CCNode* _backgroundNode;
    
}

-(void)didLoadFromCCB
{
    self.userInteractionEnabled = YES;
    [self loadLevelNamed:nil];
}

-(void)loadLevelNamed:(NSString*)levelCCB
{
    _playerNode = [self getChildByName:@"player" recursively:YES];
    NSAssert1(_playerNode, @"palyer node not found in level: %@", levelCCB);
}

-(void)touchBegan:(CCTouch*)touch withEvent: (UITouch*)event
{
    [_playerNode stopActionByTag:1];
    CGPoint pos = [touch locationInNode:_levelNode];
    CGPoint playerNode = _playerNode.position;
    CGPoint temp = ccpSub(pos, playerNode);
    CGPoint finalPos;
    if (fabs(temp.x) > 40) {
         finalPos = CGPointMake((playerNode.x + 40*(fabs(temp.x)/temp.x)), (playerNode.y + 40*(temp.y/fabs(temp.x))));
    }
    else{
        finalPos = CGPointMake((playerNode.x + temp.x), (playerNode.y + temp.y));
    }
    
    
    CCAction* move = [CCActionMoveTo actionWithDuration:0.2 position:finalPos];
    move.tag = 1;

    [_playerNode runAction:move];
}

-(void) exitButtonPressed
{
	NSLog(@"Get me outa here!");
	
	CCScene* scene = [CCBReader loadAsScene:@"MainScene"];
	CCTransition* transition = [CCTransition transitionFadeWithDuration:1.5];
	[[CCDirector sharedDirector] presentScene:scene withTransition:transition];
}

@end
