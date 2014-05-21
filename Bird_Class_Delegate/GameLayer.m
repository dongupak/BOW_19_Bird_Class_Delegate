//
//  GameLayer.m
//  Action_Move
//
//  Created by 영록 이 on 11. 8. 12..
//  Copyright 2011년 __MyCompanyName__. All rights reserved.
//

#import "GameLayer.h"
#define FRONT_CLOUD_SIZE 563
#define BACK_CLOUD_SIZE  509
#define FRONT_CLOUD_TOP  310
#define BACK_CLOUD_TOP   230
#define MAX_BULLET_COUNT 7
#define KILL_POINT       100

@implementation GameLayer

-(void)dealloc {
    [sitAnimate release];
    [tailAnimate release];
    [smokeAnimate release];
    [gunSmoke release];
    [birdArray release];
    
    [super dealloc];
}

+(CCScene *) scene
{
	CCScene *scene = [CCScene node];
	GameLayer *layer = [GameLayer node];
	[scene addChild: layer];
	return scene;
}

- (void)createCloudWithSize:(int)imgSize top:(int)imgTop fileName:(NSString*)fileName interval:(int)interval z:(int)z {
    id enterRight	= [CCMoveTo actionWithDuration:interval position:ccp(0, imgTop)];
    id enterRight2	= [CCMoveTo actionWithDuration:interval position:ccp(0, imgTop)];
    id exitLeft		= [CCMoveTo actionWithDuration:interval position:ccp(-imgSize, imgTop)];
    id exitLeft2	= [CCMoveTo actionWithDuration:interval position:ccp(-imgSize, imgTop)];
    id reset		= [CCMoveTo actionWithDuration:0  position:ccp( imgSize, imgTop)];
    id reset2		= [CCMoveTo actionWithDuration:0  position:ccp( imgSize, imgTop)];
    id seq1			= [CCSequence actions: exitLeft, reset, enterRight, nil];
    id seq2			= [CCSequence actions: enterRight2, exitLeft2, reset2, nil];
    
    CCSprite *spCloud1 = [CCSprite spriteWithFile:fileName];
    [spCloud1 setAnchorPoint:ccp(0,1)];
    [spCloud1.texture setAliasTexParameters];
    [spCloud1 setPosition:ccp(0, imgTop)];
    [spCloud1 runAction:[CCRepeatForever actionWithAction:seq1]];
    [self addChild:spCloud1 z:z ];
    
    CCSprite *spCloud2 = [CCSprite spriteWithFile:fileName];
    [spCloud2 setAnchorPoint:ccp(0,1)];
    [spCloud2.texture setAliasTexParameters];
    [spCloud2 setPosition:ccp(imgSize, imgTop)];
    [spCloud2 runAction:[CCRepeatForever actionWithAction:seq2]];
    [self addChild:spCloud2 z:z ];
}

//새를 클릭했을 시에 일어나는 연기 애니메이션을 생성하는 메소드입니다.
- (void)createGun {
    //스프라이트 프레임 케쉬에 스프라이트를 저장합니다.
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"gun.plist"];
    
    //연기 이미지를 표시하기 위해 Sprite를 이용합니다.
    gunSmoke = [[CCSprite alloc] init];
    //GameLayer에 배경 Sprite를 Child로 넣습니다. z-index는 5로 설정합니다.
    [self addChild:gunSmoke z:5];
    
    //프레임을 담을 NSMutableArray형의 smokeFrames이름의 배열을 만듭니다.
    NSMutableArray *smokeFrames = [NSMutableArray array];
    //NSInteger형의 idx변수가 1부터 10미만이 될 때까지 1씩 증가시키며 for구문을 실행시킵니다.
    for(NSInteger idx = 1; idx < 10; idx++) {
        //알맞은 이미지를 프레임에 순서대로 담습니다.
        CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"shotgun_smoke2_%04d.png",idx]];
        //프레임을 배열에 저장합니다.
        [smokeFrames addObject:frame];
    }
    //프레임으로 CCAimation을 만듭니다. 각 프레임당 시간을 0.05초로 정해줍니다.
    CCAnimation *smokeAnimation = [CCAnimation animationWithSpriteFrames:smokeFrames delay:0.05f];
    //CCAnimation에  action을 줄 CCAnimte를 만듭니다.
    smokeAnimate = [[CCAnimate alloc] initWithAnimation:smokeAnimation];
    //스프라이트 프레임 케쉬에 저장한 스프라이트를 제거합니다.
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"gun.plist"];
}

// 새가 처음에 있는 위치를 만드는 메소드입니다.
// 새가 여기저기서 날아오는 모습을 보이기 위하여 랜덤으로 위치를 설정합니다.
-(CGPoint)getStartPosition {
	int starty=0;
    // arc4random()은 랜덤으로 정수인 값을 줍니다.
    // 'arc4random()%x' 이면 0에서 x-1 값중에 하나를 줍니다.
    // x 좌표가 -30 에서 509 중에 나오도록 랜덤을 설정합니다.
    // 새 sprite 크기를 계산해서 화면에 안 보이게 하기 위해 화면 x 범위 (0 ~ 480) 보다 더 크게 잡았습니다.
    int startx = arc4random()%540-30;
    
    
    // 위에서 설정한 랜덤값이 0 보다 크고 480보다 작다면, 즉 x좌표가 화면에 보일 수 있는 위치 안이라면 안보이도록 y 좌표를 400으로 합니다.(화면의 y 범위는 0 ~ 320 입니다.)
    // x값이 화면에서 안 보이는 위치에 있다면 y 좌표를 100에서 299중에 랜덤인 값으로 설정합니다.
    if (startx>0 && startx<480) {
        starty=400;
    } else {
        starty = arc4random()%200+100;
    }
    
    // 랜덤으로 주어진 값을 반환합니다.
	return ccp(startx, starty);
}


-(void)createBird {
    
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"bluebird.plist"];
    
    // BlueBird 형 bird 객체를 생성 후, bird 의 delegate 로 연결시킵니다.
    // delegate=self 함으로서 여기 추가된 bird를 클래스에서도 다룰 수 있도록 합니다.
    
    BlueBird *bird = [[BlueBird alloc] init];
    bird.delegate=self;
    [bird setPosition:[self getStartPosition]];
    
    NSValue *value = [sitPositions objectAtIndex:arc4random()%10];
    bird.sitPoint = [value CGPointValue];
    
    [self addChild:bird z:5];
    [birdArray addObject:bird];
    [bird release];
    [bird action];
}


// 객체가 터치 되었는지 판별하는 메소드입니다.
// ccpDistance는 target 과 터치한 위치 touchPoint 간의 거리를 계산해 줍니다.
- (BOOL)isHitWithTarget:(CCSprite *)target touchPoint:(CGPoint)touchPoint {
    // target과 touchPoint 간의 거리가 (target의 크기/2) 이면 터치한 것으로 판단하여 YES 값을 반환합니다.
	if(ccpDistance(target.position, touchPoint) < target.contentSize.width /2) return YES;
    // 그러지 않다면 NO 값을 반환합니다.
	return NO;
}


// 객체가 터치 되었는지 판별하는 메소드입니다.
// ccpDistance 을 사용하지 않는 방법입니다.
- (BOOL)isTouchInside:(CCSprite*)sprite touchPoint:(CGPoint)touchPoint {
	CGFloat halfWidth   = sprite.contentSize.width /2.0;
	CGFloat halfHeight  = sprite.contentSize.height /2.0;
    
    // touchPoint 가 sprite의 넓이 외에 있으면 터치되지 않은 것으로 판별하여 NO 값을 반환합니다.
	if (touchPoint.x>(sprite.position.x+halfWidth) ||
		touchPoint.x<(sprite.position.x-halfWidth) ||
		touchPoint.y<(sprite.position.y-halfHeight)||
		touchPoint.y>(sprite.position.y+halfHeight) )		{
		return NO;
	}
    
    // 그렇지 않다면 YES 값을 반환합니다.
	return YES;
}


-(void)birdisDead:(Bird *)bird {
    score += 100;
    [lblScore setString:[NSString stringWithFormat:@"SCORE : %d",score]];
    
    // 새가 죽었을 때 동작은 클래스 Bird 의 메소드 setIsDead: 로 동작을 줍니다.
    // 클래스 안에 tailAnimate가 있기 때문에 코드가 줄어들었습니다.
    // 하지만 removeChild가 되지 않아 bird를 지우지 못했습니다. <- 다음 프로젝트에서 해결합니다.
    [bird setIsDead:YES];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setObject:[NSNumber numberWithInt:score] forKey:@"score"];
	[userDefaults synchronize];
    
    
    //    id tailComplete = [CCCallFuncN actionWithTarget:self selector:@selector(removeBird:)];
    //    id actionSeq = [CCSequence actions:tailAnimate, tailComplete, nil];
    //    [bird runAction:actionSeq];
}


-(id) init
{
	if( (self=[super init])) {
        // CCLayer가 시스템으로부터 넘어온 터치 이벤트에 대해 프로토콜의 메서드를 호출하게 합니다.
        // 만일 NO로 설정하면 터치 이벤트가 발생해도 터치 이벤트를 처리하는 메서드가 호출되지 않습니다.
        self.isTouchEnabled = YES;
        
        bulletCount = MAX_BULLET_COUNT;
        //총이 쐈을 경우를 위한 사운드 효과를 preload를 사용하여 미리 메모리에 올려 놓습니다.
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"handgun_fire.wav"];
        //배경음악을 위한 음악을 preload를 사용하여 미리 메모리에 올려 놓습니다.
        [[SimpleAudioEngine sharedEngine] preloadBackgroundMusic:@"bird.m4a"];
        //게임이 시작되면 배경 백그라운드 음악이 재생됩니다.
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"bird.m4a" loop:YES];
        //배경 백그라운드 음악의 음량을 0.5로 조절합니다.
        [[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume:0.5f];
        //사운드 효과의 음량을 0.5로 지정합니다.
        [[SimpleAudioEngine sharedEngine] setEffectsVolume:0.5f];
        
        // CCArray 형 birdArray를 만듭니다.
        // CCArray는 cocos2d 에서 제공하는 배열입니다.
        // birdArray는 생성되는 bird를 담아두는 배열입니다.
        // 후에 bird sprite를 충돌 검사를 할 시에 쓰입니다.
        birdArray = [[CCArray alloc] init];
        
        CCSprite *back = [CCSprite spriteWithFile:@"back.png"];
        [back setPosition:ccp(240, 160)];
        [self addChild:back z:0];
        
        CCSprite *setting = [CCSprite spriteWithFile:@"setting.png"];
        [setting setPosition:ccp(240, 160)];
        [self addChild:setting z:2];
        
        CCSprite *pole = [CCSprite spriteWithFile:@"pole.png"];
        [pole setAnchorPoint:ccp(0.5f, 0.0f)];
        [pole setPosition:ccp(240, 0)];
        [self addChild:pole z:2];
        
        //총의 종류를 나타내는 이미지를 생성
        CCSprite *spGun = [CCSprite spriteWithFile:@"ui_handgun.png"];
        //이 이미지의 anchorPoint와 위치를 지정합니다.
        spGun.anchorPoint = ccp(0.5, 0.5);
        spGun.position = ccp(40,280);
        //spGun을 GameLayer의 자식으로 둡니다. z 값은 6으로 지정합니다.
        [self addChild:spGun z:6];
        
        //총알의 이미지 자체를 나타내는 스프라이트 ptBulletSprite를 "bullet_handgun.png"로 지정합니다.
        ptBulletSprite = [CCSprite spriteWithFile:@"bullet_handgun.png"];
        //총알의 개수를 CCProgressTimer를 이용하여 나타내는 ptBullet의 이미지를 위에서 정의한 ptBulletSprite로 지정합니다.
        ptBullet = [CCProgressTimer progressWithSprite:ptBulletSprite];
        
        //ptBullet의 형태를 수평막대형으로 지정합니다.
        ptBullet.type = kCCProgressTimerTypeBar;
        //ptBullet의 anchorPoint와 위치를 지정합니다.
        ptBullet.anchorPoint = ccp(0, 0.5f);
        ptBullet.position = ccp(80, 285);
        //ptBullet의 총알 이미지가 줄어드는 형태를 지정해주는 옵션입니다. ccp(1,0)으로 지정하면 가로로 이미지가 줄어들고 ccp(0,1)로 지정하면 세로로 이미지가 줄어듭니다.
        ptBullet.barChangeRate = ccp(1,0);
        //ptBullet의 총알 이미지가 줄어드는 방향(왼쪽 또는 오른쪽)을 지정해주는 옵션입니다. ccp(0,1)이면 오른쪽부터 이미지가 줄어들고 ccp(1,0)이면 왼쪽부터 이미지가 줄어듭니다.
        ptBullet.midpoint = ccp(0,1);
        //ptBullet의 비율을 100으로 잡습니다.
        ptBullet.percentage=100;
        //ptBullet을 GameLayer의 자식으로 둡니다. z 값은 21로 지정합니다.
        [self addChild:ptBullet z:21];
        
        //재장전되는 과정을 나타내는 스프라이트 ptReloadSprite를 "reload_bar.png"로 지정합니다.
        ptReloadSprite = [CCSprite spriteWithFile:@"reload_bar.png"];
        //재장전되는 과정을 나타내는 ProgressTimer를 이용하여 나타내는 ptReload의 이미지를 위에서 정의한 ptReloadSprite로 지정합니다.
        ptReload = [CCProgressTimer progressWithSprite:ptReloadSprite];
        //ptReload의 형태를 수평막대형으로 지정합니다.
        ptReload.type = kCCProgressTimerTypeBar;
        //ptReload의 anchorPoint와 위치를 지정합니다.
        ptReload.anchorPoint = ccp(.5f, .5f);
        ptReload.position = ccp(40, 285);
        //ptReload의 줄어드는 방향, 줄어드는 정도 등 여러가지 옵션을 설정합니다.(여기서는 오른쪽부터 수평으로만 줄어들게 설정했습니다.)
        ptReload.barChangeRate = ccp(1, 0);
        ptReload.midpoint = ccp(0, .5);
        //ptReload의 비율을 0으로 잡습니다.(처음에는 총알이 최대치로 장전되어있으므로 비율을 0으로 하여 안 보이게 해 놓아야 하기 때문입니다.)
        ptReload.percentage=0;
        //총의 종류를 나타내는 스프라이트 spGun의 앞쪽에 위치해야 하므로 z값을 더 크게 잡았습니다.(spGun의 z값 : 6, ptReload의 z값 : 9)
        [self addChild:ptReload z:9];

        //score 레이블을 초기화 한다.
        lblScore = [CCLabelBMFont labelWithString:@"SCORE : 0" fntFile:@"17YBsh.fnt"];
        [lblScore setAnchorPoint:ccp(1, 0)];
        [lblScore setPosition:ccp(473, 5)];
        [self addChild:lblScore z:9];
        
        //가벼운 데이터를 저장할 수 있는 NSUserDefaults 를 만든다.
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSLog(@"%d",[[userDefaults objectForKey:@"score"] intValue] );
        //NSUserDefaults에 저장되어 있는 score 값을 불러온다.
        score=[[userDefaults objectForKey:@"score"] intValue];
        [lblScore setString:[NSString stringWithFormat:@"SCORE : %d",score]];
        
        [self createCloudWithSize:FRONT_CLOUD_SIZE top:FRONT_CLOUD_TOP fileName:@"cloud_front.png" interval:15 z:2];
        [self createCloudWithSize:BACK_CLOUD_SIZE  top:BACK_CLOUD_TOP  fileName:@"cloud_back.png"  interval:30 z:1];
        
        [self createGun];
        
        // 배열에 NSValue 형태로 CGPoint 값을 넣습니다.
        // CGPoint, CGRect 등의 기본 자료형들은 NSArray, Dicionary 등에 바로 쓸 수 없습니다. 객체만 받아들이기 때문입니다.
        // 그래서 기본 자료형들을 NSValue로 형태를 변환시킨 후 넣어야 합니다.
        // 이런 과정을 레핑(Wrapping) 이라고 합니다.
        // NSValue는 CGPoint, CGRect 등을 객체화시키고,
        // NSNumber은 int, float 등을 객체화 시킵니다.
        sitPositions = [NSArray arrayWithObjects:
                        [NSValue valueWithCGPoint:ccp(70,  193)],
                        [NSValue valueWithCGPoint:ccp(107, 178)],
                        [NSValue valueWithCGPoint:ccp(144, 167)],
                        [NSValue valueWithCGPoint:ccp(181, 158)],
                        [NSValue valueWithCGPoint:ccp(218, 155)],
                        [NSValue valueWithCGPoint:ccp(255, 156)],
                        [NSValue valueWithCGPoint:ccp(292, 161)],
                        [NSValue valueWithCGPoint:ccp(329, 168)],
                        [NSValue valueWithCGPoint:ccp(366, 180)],
                        [NSValue valueWithCGPoint:ccp(403, 195)],
                        nil];
        // 내부의 retainCount 를 하나 늘린다.
        [sitPositions retain];
        
        //        [self createBird];
        //3초 간격으로 createBird 메소드를 호출한다.
        [self schedule:@selector(createBird) interval:2.0f];
    }
	return self;
}

#pragma mark -
#pragma mark BirdDelegate Protocol
// BirdDelegate Protocol 부분입니다.
// Bird랑 연결시켜, GameLayer에서 Bird 처리를 할 수 있는 부분입니다.
// GameLayer에서 추가된 Bird형 bird를 제거하는 메소드입니다.
-(void)deadComplete:(Bird *)bird {
    [self removeChild:bird cleanup:YES];
}

#pragma mark -
#pragma mark TouchHandler

-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    // touch 라는 문구를 출력합니다.
    NSLog(@"touch");
    
    // 화면의 터치하는 곳의 좌표를 glLocation으로 정의하고 glLocation인 곳에서 연기를 나타내는 스프라이트인 gunSmoke를 나타나게합니다.
	UITouch *touch = [touches anyObject];
	CGPoint location = [touch locationInView:[touch view]];
	CGPoint glLocation = [[CCDirector sharedDirector] convertToGL:location];
	[gunSmoke setPosition:glLocation];
    
    //남은 총알의 개수가 0보다 크다면 안의 코드들을 수행한다.
    if (bulletCount>0) {
        //남은 총알의 개수를 하나 감소시킨다.
        bulletCount -=1;
        ptBullet.percentage = bulletCount *100 / MAX_BULLET_COUNT;
        
        //연기 애니메이션을 나타내는 smokeAnimate가 일어나지 않으면 gunSmoke가 smokeAnimate를 하지않게 합니다.
        if (![smokeAnimate isDone]) [gunSmoke stopAction:smokeAnimate];
        //gunSmoke가 smokeAnimate를 수행하게 합니다.
        [gunSmoke runAction:smokeAnimate];
        //사운드 효과를 재생한다.
        [[SimpleAudioEngine sharedEngine] playEffect:@"handgun_fire.wav"];
        for (Bird *bird in birdArray)
        {
            if ([self isHitWithTarget:bird touchPoint:glLocation]) [self birdisDead:bird];
        }
    } //총알이 0이 된다면
    else {
        //ptReload이미지는 99%부터 시작해서
        ptReload.percentage = 99;
        //2초동안 0%가 될 때 까지 줄어 든다.
        id actionReload = [CCProgressTo actionWithDuration:2 percent:0];
        //위 액션이 끝나면 다음 함수 수행
        id reloadComplete = [CCCallFunc actionWithTarget:self selector:@selector(endReload)];
        id actionSeq    = [CCSequence actions:actionReload, reloadComplete, nil];
        //ptReload이미지가 위 액션들을 순차적으로 수행한다.
        [ptReload runAction:actionSeq];
        
    }
}
- (void)endReload {
    //총알을 최대 개수로 올리고
    bulletCount = MAX_BULLET_COUNT;
    //총알이미지 다시 다 나오게 됨.
    ptBullet.percentage = bulletCount *100 / MAX_BULLET_COUNT;
    //재장전 소리 나옴
    [[SimpleAudioEngine sharedEngine] playEffect:@"handgun_reload.wav"];
}

-(void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
}

-(void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
}

@end
