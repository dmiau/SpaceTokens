//
//  PointInformationSheet.m
//  SpaceBar
//
//  Created by dmiau on 2/9/17.
//  Copyright © 2017 dmiau. All rights reserved.
//

#import "PointInformationSheet.h"
#import "AppDelegate.h"
#import "ViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImage+tools.h"
#import "EntityDatabase.h"

#define INITIAL_HEIGHT 60
@implementation PointInformationSheet

-(void)awakeFromNib{
    [super awakeFromNib];
    
    // Initialize the object
    self.titleOutlet.delegate = self;
    
    [self.starOutlet setImage:
     [[UIImage imageNamed:@"starGray-128.png"] resize:CGSizeMake(30, 30)]
                     forState:UIControlStateNormal];
    [self.starOutlet setImage:
     [[UIImage imageNamed:@"star-128.png"] resize:CGSizeMake(30, 30)]
                     forState:UIControlStateSelected];
}


-(void)updateSheet{
    self.titleOutlet.text = self.spatialEntity.name;
    if (self.spatialEntity.annotation.pointType == STAR){
        [self.starOutlet setSelected:YES];
    }else{
        [self.starOutlet setSelected:NO];
    }
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{

    if([keyPath isEqualToString:@"dirtyFlag"] && object == self.spatialEntity)
    {
        [self updateSheet];
    }
}

// MARK: Setters
//-------------------------------------
-(void)setSpatialEntity:(SpatialEntity *)spatialEntity{

    // Remove the previous observer
    if (self.spatialEntity){
        [self.spatialEntity removeObserver:self forKeyPath:@"dirtyFlag"];
    }
    
    [super setSpatialEntity:spatialEntity];
    
    // Add a new observer
    [spatialEntity addObserver:self forKeyPath:@"dirtyFlag" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                       context:nil];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    //---------------
    // Rename a token
    //---------------
    self.spatialEntity.name = self.titleOutlet.text;
    
    // Find all the tokens with the same spatial entity
    for (SpaceToken *token in [[TokenCollection sharedManager] getTokenArray]){
        if (token.spatialEntity == self.spatialEntity){
            [token
             setTitle: self.titleOutlet.text
             forState: UIControlStateNormal];
        }
    }
    
    [self.titleOutlet resignFirstResponder];
    
    // Need to shift the panel down
    CGRect superFrame = self.superview.frame;
    CGRect frame = CGRectMake(0, superFrame.size.height - INITIAL_HEIGHT,
                              self.frame.size.width, self.frame.size.height);
    self.frame = frame;
    
    return YES;
}

- (IBAction)starAction:(id)sender {
    
    SpatialEntity *entity = self.spatialEntity;
    
    if (entity.annotation.pointType == STAR){
        // de-star
        [[EntityDatabase sharedManager] removeEntity:entity];
        entity.annotation.pointType = DEFAULT_MARKER;
    }else{
        // star the location
        [[EntityDatabase sharedManager] addEntity:entity];
        entity.annotation.isHighlighted = YES;
        
    }
    entity.dirtyFlag = @0;
}
@end
