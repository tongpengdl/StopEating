//
//  GameScene.m
//  StopEating
//
//  Created by peng tong on 4/27/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "GameScene.h"
#import "cocos2d.h"
#import "gameOver.h"
#import "gameWin.h"

@implementation GameScene
{
	__weak CCNode* _levelNode;
	__weak CCPhysicsNode* _physicsNode;
	__weak CCNode* _playerNode;
	__weak CCNode* _backgroundNode;
    __weak CCNode* _scaleupNode;
    __weak CCNode* _scaledownNode;
    __weak CCLabelTTF* _timeLabel;
    
    
    CGFloat _playerNudgeRightVelocity;
    CGFloat _playerNudgeUpVelocity;
    CGFloat _playerMaxVelocity;
    
    NSString* _timeLabelString;
    
    BOOL _acceleratePlayer;

    BOOL _drawPhysicsShapes;
    
    BOOL _gameover;
    

}

-(void) didLoadFromCCB
{
	// enable receiving input events
	self.userInteractionEnabled = YES;
    self.second=0;
    _gameover=NO;
	// load the current level
	[self loadLevelNamed:nil];

	
	NSLog(@"_levelNode = %@", _levelNode);
}

-(void) loadLevelNamed:(NSString*)levelCCB
{
	_physicsNode = (CCPhysicsNode*)[_levelNode getChildByName:@"physics" recursively:NO];
	_backgroundNode = [_levelNode getChildByName:@"background" recursively:NO];
	_playerNode = [_physicsNode getChildByName:@"player" recursively:YES];
    
    _physicsNode.debugDraw=false;
    
    _physicsNode.collisionDelegate=self;
    
    CCNode* sawNoAutoplay = [_physicsNode getChildByName:@"sawNoAutoplay" recursively:YES];
    [sawNoAutoplay.animationManager runAnimationsForSequenceNamed:@"Default Timeline"];
    
     [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateTimer:) userInfo:nil repeats:YES];

}

-(void) touchBegan:(CCTouch *)touch withEvent:(UIEvent *)event
{
    _acceleratePlayer=YES;
}

-(void) touchEnded:(CCTouch *)touch withEvent:(CCTouchEvent *)event
{
    _acceleratePlayer=NO;
}

-(void) touchCancelled:(CCTouch *)touch withEvent:(CCTouchEvent *)event
{
    [self touchEnded:touch withEvent:event];
}

-(void) update:(CCTime)delta
{

    if(_playerNode.position.y<-_playerNode.contentSize.height)
    {
        [_playerNode removeFromParent];
        [self gameOver];
    }

    if(_acceleratePlayer){
        [self accelerateTarget:_playerNode];
    }
    
    [self scrollToTarget:_playerNode];
    
}

-(void) accelerateTarget:(CCNode*)target
{
    
    CCPhysicsBody* physicsBody = target.physicsBody;
    
    if(physicsBody.velocity.x<0){
        physicsBody.velocity = CGPointMake(0.0, physicsBody.velocity.y);
    }
    
    [physicsBody applyImpulse:CGPointMake(_playerNudgeRightVelocity, _playerNudgeUpVelocity)];
    
    if (ccpLength(physicsBody.velocity)>_playerMaxVelocity) {
        CGPoint direction = ccpNormalize(physicsBody.velocity);
        physicsBody.velocity = ccpMult(direction, _playerMaxVelocity);
    }
    
}


-(bool)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair player:(CCNode *)player die:(CCNode *)die
{
    _gameover=NO;
    [self gameOver];
    return YES;
}

-(bool)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair player:(CCNode *)player scaleDown:(CCNode *)scaleDown
{
    NSLog(@"scale down");
    CCActionScaleBy* reduce = [CCActionScaleBy actionWithDuration:1.0 scale:0.9];
    [player runAction:reduce];
    
    return YES;
}

-(bool)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair player:(CCNode *)player scaleUp:(CCNode *)scaleUp
{
    NSLog(@"scale up");
    CCActionScaleBy* grow = [CCActionScaleBy actionWithDuration:1.0 scale:1.2];
    [player runAction:grow];
    
    return YES;
}

-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair player:(CCNode *)player exit:(CCNode *)exit
{
    [self gameWin];
    [player removeFromParent];
    [exit removeFromParent];
    return NO;
}


-(void) scrollToTarget:(CCNode*)target
{
	CGSize viewSize = [CCDirector sharedDirector].viewSize;
	CGPoint viewCenter = CGPointMake(viewSize.width / 2.0, viewSize.height / 2.0);
	
	CGPoint viewPos = ccpSub(target.positionInPoints, viewCenter);
	
	CGSize levelSize = _levelNode.contentSizeInPoints;
	viewPos.x = MAX(0.0, MIN(viewPos.x, levelSize.width - viewSize.width));
	viewPos.y = MAX(0.0, MIN(viewPos.y, levelSize.height - viewSize.height));
	
	_physicsNode.positionInPoints = ccpNeg(viewPos);
	
	
	
	CGPoint viewPosPercent = CGPointMake(viewPos.x / (levelSize.width - viewSize.width),
										 viewPos.y / (levelSize.height - viewSize.height));
	
	for (CCNode* layer in _backgroundNode.children)
	{
		CGSize layerSize = layer.contentSizeInPoints;
		CGPoint layerPos = CGPointMake(viewPosPercent.x * (layerSize.width - viewSize.width),
									   viewPosPercent.y * (layerSize.height - viewSize.height));
		layer.positionInPoints = ccpNeg(layerPos);
	}
}



-(void)updateTimer:(NSTimer *)timer
{
    self.second = self.second + 1;
    if(_gameover){
        [timer invalidate];
    }
    self.n = self.n + 1;
    _timeLabel.string=[NSString stringWithFormat:@"%d s", self.n];
    
    NSLog(@"%d",self.n);
}


-(void)gameOver
{
    if (!_gameover) {
        NSLog(@"gameover");
        _gameover=YES;
        
        _playerNode.rotation=90.f;
        _playerNode.physicsBody.allowsRotation=NO;
        [self stopAllActions];
        self.userInteractionEnabled=NO;
        
        gameOver* gameEndPopover=(gameOver*) [CCBReader load:@"gameOver"];
        gameEndPopover.positionType = CCPositionTypeNormalized;
        gameEndPopover.position = ccp(0.5, 0.5);
        gameEndPopover.zOrder = INT_MAX;
        [self addChild:gameEndPopover];
    }
    
}

-(void)gameWin
{
    _gameover=YES;
    gameWin* gameWinPopover=(gameWin*) [CCBReader load:@"gameWin"];
    gameWinPopover.positionType = CCPositionTypeNormalized;
    gameWinPopover.position = ccp(0.21, 0.15);
    gameWinPopover.zOrder = INT_MAX;
    [self addChild:gameWinPopover];

    
}

@end
