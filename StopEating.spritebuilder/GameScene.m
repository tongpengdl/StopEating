//
//  GameScene.m
//
//
//

#import "GameScene.h"
#import "cocos2d.h"

@implementation GameScene
{
	__weak CCNode* _levelNode;
	__weak CCPhysicsNode* _physicsNode;
	__weak CCNode* _playerNode;
	__weak CCNode* _backgroundNode;
    __weak CCNode* _scaleupNode;
    __weak CCNode* _scaledownNode;
    
    
    CGFloat _playerNudgeRightVelocity;
    CGFloat _playerNudgeUpVelocity;
    CGFloat _playerMaxVelocity;
    BOOL _acceleratePlayer;

    BOOL _drawPhysicsShapes;
    
    BOOL _gameover;
    
    CCButton* _restartButton;

}

-(void) didLoadFromCCB
{
	// enable receiving input events
	self.userInteractionEnabled = YES;
	
	// load the current level
	[self loadLevelNamed:nil];
	
	NSLog(@"_levelNode = %@", _levelNode);
}

-(void) loadLevelNamed:(NSString*)levelCCB
{
	_physicsNode = (CCPhysicsNode*)[_levelNode getChildByName:@"physics" recursively:NO];
	_backgroundNode = [_levelNode getChildByName:@"background" recursively:NO];
	_playerNode = [_physicsNode getChildByName:@"player" recursively:YES];
    _scaleupNode = [_physicsNode getChildByName:@"scaleupstar" recursively:YES];
    _scaledownNode = [_physicsNode getChildByName:@"scaledownstar" recursively:YES];
    
    _physicsNode.debugDraw=false;
    
    _physicsNode.collisionDelegate=self;
    
    CCNode* sawNoAutoplay = [_physicsNode getChildByName:@"sawNoAutoplay" recursively:YES];
    [sawNoAutoplay.animationManager runAnimationsForSequenceNamed:@"Default Timeline"];
	
	NSAssert1(_physicsNode, @"physics node not found in level: %@", levelCCB);
	NSAssert1(_backgroundNode, @"background node not found in level: %@", levelCCB);
	NSAssert1(_playerNode, @"player node not found in level: %@", levelCCB);
    NSAssert1(_scaleupNode, @"scaleup star not found in level: %@", levelCCB);
    NSAssert1(_scaledownNode, @"scaledown star not found in level: %@", levelCCB);
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
    }

    if(_acceleratePlayer){
        [self accelerateTarget:_playerNode];
    }
    
    [self scrollToTarget:_playerNode];
    
}

-(void) accelerateTarget:(CCNode*)target
{

    //_playerMaxVelocity =100.0;
    //_playerNudgeRightVelocity =30.0;
    //_playerNudgeUpVelocity =80.0;
    
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


-(bool)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair player:(CCNode *)player wildcard:(CCNode *)wildcard
{
    _gameover=NO;
    [self gameOver];
    NSLog(@"collision - player: %@, wildcard: %@", player, wildcard);
    return YES;
}

-(void) exitButtonPressed
{
	CCScene* scene = [CCBReader loadAsScene:@"MainScene"];
	CCTransition* transition = [CCTransition transitionFadeWithDuration:1.5];
	[[CCDirector sharedDirector] presentScene:scene withTransition:transition];
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

-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair player:(CCNode *)player exit:(CCNode *)exit
{
    [self gameOver];
    [player removeFromParent];
    [exit removeFromParent];
    return NO;
}

-(void)gameOver
{
    if (!_gameover) {
        NSLog(@"gameover");
        _gameover=YES;
        _restartButton.visible=YES;
        
        _playerNode.rotation=90.f;
        _playerNode.physicsBody.allowsRotation=NO;
        [self stopAllActions];
        self.userInteractionEnabled=NO;
        
        CCActionMoveBy *moveBy = [CCActionMoveBy actionWithDuration:0.2f position:ccp(-2, 2)];
        CCActionInterval *reverseMovement = [moveBy reverse];
        CCActionSequence *shakeSequence = [CCActionSequence actionWithArray:@[moveBy, reverseMovement]];
        CCActionEaseBounce *bounce = [CCActionEaseBounce actionWithAction:shakeSequence];

        [self runAction:bounce];
    }
    
}

@end
