//
//  CollectionInformationSheet.m
//  SpaceBar
//
//  Created by dmiau on 2/9/17.
//  Copyright © 2017 dmiau. All rights reserved.
//

#import "CollectionInformationSheet.h"
#import "AppDelegate.h"
#import "ViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImage+tools.h"
#import "EntityDatabase.h"


#define INITIAL_HEIGHT 60
@implementation CollectionInformationSheet

-(void)awakeFromNib{
    [super awakeFromNib];
    
    // Initialize the object
    self.titleOutlet.delegate = self;
    
    [self.starOutlet setTitle:@"remove" forState:UIControlStateNormal];
}

-(void)addSheetForEntity:(SpatialEntity*)entity{
    [super addSheetForEntity:entity];
    [self.starOutlet setTitle:@"remove" forState:UIControlStateNormal];
}

-(void)updateSheet{        
    self.titleOutlet.text = self.spatialEntity.name;

    self.detailTextView.text = self.spatialEntity.description;
}

// MARK: Setters
//-------------------------------------
//-(void)setSpatialEntity:(SpatialEntity *)spatialEntity{
//    _spatialEntity = spatialEntity;
//    self.titleOutlet.text = spatialEntity.name;
//}

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
    if ([self.starOutlet.titleLabel.text isEqualToString: @"remove"]){
        [[EntityDatabase sharedManager] removeEntity:entity];
        [self.starOutlet setTitle:@"save" forState:UIControlStateNormal];
    }else{
        [[EntityDatabase sharedManager] addEntity:entity];
        [self.starOutlet setTitle:@"remove" forState:UIControlStateNormal];
    }

    [self updateSheet];
}


@end
