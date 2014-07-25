//
//  ViewController.m
//  Egg
//
//  Created by Gin on 7/21/14.
//  Copyright (c) 2014 Nguyễn Huỳnh Lâm. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AudioToolbox/AudioToolbox.h>
@interface ViewController () <AVAudioPlayerDelegate>
{
    NSTimer *timer,*timer1;
    int x,y,count,countTime,point,wrong;
    double time,time1;
    UIView* piece;
    AVAudioPlayer *audioPlayer;
    SystemSoundID Soundwr,Soundcr;
}

@property (weak, nonatomic) IBOutlet UIImageView *showOver;
@property (weak, nonatomic) IBOutlet UILabel *showPoint;
@property (weak, nonatomic) IBOutlet UIImageView *basketEgg;
@property (strong, nonatomic) IBOutlet UIImageView *photo;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIPanGestureRecognizer* pan1 = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panObject:)];
    [self.basketEgg addGestureRecognizer:pan1];
    
    UISwipeGestureRecognizer* swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(showGestureForSwipeRecognizer:)];
	[self.view addGestureRecognizer: swipe];
    
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSString *filePath = [mainBundle pathForResource:@"sound"
                                              ofType:@"mp3"];
    NSData *fileData = [NSData dataWithContentsOfFile:filePath];
    NSError *error = nil;
    self->audioPlayer = [[AVAudioPlayer alloc] initWithData:fileData
                                                      error:&error];
    audioPlayer.delegate = self;
    audioPlayer.numberOfLoops = -1;
    [self->audioPlayer play];

    NSURL *soundX = [NSURL fileURLWithPath:[[NSBundle mainBundle]	pathForResource:@"wrongSound" ofType:@"mp3"]];
    AudioServicesCreateSystemSoundID((__bridge  CFURLRef) soundX, 	&Soundwr);
    NSURL *soundY = [NSURL fileURLWithPath:[[NSBundle mainBundle]	pathForResource:@"correctSound" ofType:@"wav"]];
    AudioServicesCreateSystemSoundID((__bridge  CFURLRef) soundY, 	&Soundcr);

    [self solve];
   
}

-(void) solve
{
    count = 0;
    point = 0;
    wrong = 0;
    time = 1;

    self.showPoint.text = @"0";
    
    for(int i=1;i<=3;i++)
    {
        UIImageView *egg = (UIImageView*)[self.view viewWithTag:i];
        egg.image = [UIImage imageNamed: @"eggA.png"];
 
        UIImageView * eggBreak = (UIImageView*)[self.view viewWithTag:i + 100];
        eggBreak.image = nil;
    }
    
    [self Timer];
}

-(void) Timer
{
    timer = nil;
    timer1 = nil;
    
    timer = [NSTimer scheduledTimerWithTimeInterval:time target:self selector:@selector(startTimer) userInfo:nil repeats: YES];
    
    [timer fire];
}


-(void) showAlert
{
    _showOver.center = CGPointMake(160, 259);
    _showOver.image = [UIImage imageNamed:@"GameOver.png"];
    _showOver.alpha = 1.0;
}

- (IBAction)showGestureForSwipeRecognizer:(UISwipeGestureRecognizer *)recognizer {
    if(wrong >= 3)
    {
        [UIView animateWithDuration:0.5 animations:^{
            self.showOver.alpha = 0.0;
            self.showOver.center =  CGPointMake(320, _showOver.center.y);
        }];
        
        [self solve];
        
    }
}

-(void) startTimer
{
    [timer1 invalidate];
    if(wrong >= 3)
    {
        [timer invalidate];
        [self showAlert];
        return;
    }
    
    count++;
    
    countTime = 0;
    
    if(count == 1)
        return;
    
    x = 20 + arc4random()%290;
    y = 50;
    
    _photo.center = CGPointMake(x,y);
    int tmp = rand()%10;
    
    if(tmp%7 == 0)
    {
        UIImage *imgg = [UIImage imageNamed:@"eggB.png"];
        _photo.image = imgg;
    }
    else
    {
        UIImage *imgg = [UIImage imageNamed:@"eggA.png"];
        _photo.image = imgg;
    }

    
    time1 = (double)time/259.0;
    
    [self subTimer];

}

-(void) subTimer
{
    timer1 = nil;
    
    timer1 = [NSTimer scheduledTimerWithTimeInterval:time1 target:self selector:@selector(startTimer1) userInfo:nil repeats: YES];
    
    [timer1 fire];

}
-(void) isWrong
{
    wrong++;
    AudioServicesPlaySystemSound(Soundwr);
    
    UIImageView *egg = (UIImageView*)[self.view viewWithTag:wrong];
    egg.image = nil;

}

-(void) isCorrect
{
    point++;
    AudioServicesPlaySystemSound(Soundcr);

}

-(void) startTimer1
{

    if(countTime >= 258) //  rơi xuống đất
    {
        countTime = 0;
        
        if([_photo.image isEqual: [UIImage imageNamed:@"eggA.png"]])
        {
            [self isWrong];
        
            UIImageView * eggBreak = (UIImageView*)[self.view viewWithTag:wrong + 100];
            eggBreak.center = CGPointMake(x, y-5);
            eggBreak.image = [UIImage imageNamed: @"breakEgg2.png"];
        }
        
        _photo.image = nil;
        
        [timer1 invalidate];
        return;
    }
    else
        countTime++;

    
    _photo.center = CGPointMake(x, y);

    
 if((_photo.center.x + (_photo.bounds.size.width)/2  <= [piece center].x + (self.basketEgg.bounds.size.width)/2) && (_photo.center.x + (_photo.bounds.size.width)/2  >= [piece center].x - (self.basketEgg.bounds.size.width)/2)  && _photo.center.y + (_photo.bounds.size.height)/2 == self.basketEgg.center.y - (self.basketEgg.bounds.size.height) /2 ) // hứng trúng
    {
        if([_photo.image isEqual: [UIImage imageNamed:@"eggA.png"]])
            [self isCorrect];
        else
            [self isWrong];
        
        self.showPoint.text = [NSString stringWithFormat:@"%d",point];
        _photo.image = nil;
        
        
        
        if(point %4 == 0 && point <= 20 ) // max speed 0.5
        {
            [timer invalidate];
            [timer1 invalidate];
            
            time -= 0.1;
            [self Timer];
            return;
        }
        [timer1 invalidate];
        return;
    }
    
    if(countTime <=259)
        y+=2;
    else
        [timer1 invalidate];

}

- (void) panObject: (UIPanGestureRecognizer*) gestureRecognizer // di chuyển rổ
{
    piece = gestureRecognizer.view;
    
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan || [gestureRecognizer state] == UIGestureRecognizerStateChanged) {
        CGPoint translation = [gestureRecognizer translationInView:[piece superview]];
        [piece setCenter:CGPointMake([piece center].x + translation.x, [piece center].y )];
        
        [gestureRecognizer setTranslation:CGPointZero inView:[piece superview]];
    }
    
}
@end
