//
//  MagicCodeViewController.m
//  VisualPairingHack
//
//  Created by Guilherme Rambo on 23/02/19.
//  Copyright © 2019 Guilherme Rambo. All rights reserved.
//

#import "MagicCodeViewController.h"

#import "VisualPairing.h"

@interface MagicCodeViewController () <UITextFieldDelegate>

@property (nonatomic, strong) IBOutlet UIView *codeContainer;
@property (nonatomic, strong) IBOutlet VPPresenterView *codeView;


@end

@implementation MagicCodeViewController


- (void)viewDidLoad {
    [super viewDidLoad];

}

- (void)_configureAsPresenter
{

    [self _installParticles];

    self.codeView = [[NSClassFromString(@"VPPresenterView") alloc] init];
    self.codeView.layer.borderWidth = 0;
    self.codeContainer.layer.borderWidth = 0;
    [self.codeView setVerificationCode:@"Hello, world"];

}

- (void)_installParticles
{
    NSData *assetData = [[NSDataAsset alloc] initWithName:@"particles"].data;
    if (!assetData) return;

    NSDictionary *caar = [NSKeyedUnarchiver unarchiveObjectWithData:assetData];
    CALayer *rootLayer = caar[@"rootLayer"];
    if (!rootLayer) return;

    [self.codeContainer.layer addSublayer:rootLayer];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self _configureAsPresenter];

    [self.codeView start];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.codeView stop];

    self.codeView.verificationCode = textField.text;

    [self.codeView start];


    return YES;
}

@end
