//
//  MainController.m
//  iOSPlayerExample
//
//  Created by eric on 16/9/30.
//  Copyright © 2016年 pengguangbo. All rights reserved.
//

#import "MainController.h"
#import "VitamioVPVC.h"
#import "ListCell.h"

@interface MainController ()

@property (nonatomic, strong) NSArray *elements;

@end

@implementation MainController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"列表";
    
    UINib *nib = [UINib nibWithNibName:_listCellId bundle:[NSBundle mainBundle]];
    [self.tableView registerNib:nib forCellReuseIdentifier:_listCellId];
    
    [self reloadElements];
    
    self.refreshControl = [UIRefreshControl new];
    [self.refreshControl addTarget:self action:@selector(reloadElements) forControlEvents:UIControlEventValueChanged];
}

- (void)reloadElements
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [paths objectAtIndex:0];
    NSArray *subPaths = [[NSFileManager defaultManager] subpathsAtPath:docDir];
    
    NSMutableArray *array = [NSMutableArray new];
    for (NSString *subPath in subPaths) {
        NSString *filePath = [NSString stringWithFormat:@"%@/%@", docDir, subPath];
        BOOL isDir;
        [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDir];
        if (!isDir) {
            [array addObject:subPath];
        }
    }
    self.elements = array;
    [self.tableView reloadData];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.refreshControl endRefreshing];
    });
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.elements.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ListCell *cell = [tableView dequeueReusableCellWithIdentifier:_listCellId];
    NSString *name = self.elements[indexPath.row];
    cell.textLabel.text = name;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [paths objectAtIndex:0];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", docDir, self.elements[indexPath.row]];
    NSLog(@"%@", filePath);
    NSURL *url = [NSURL fileURLWithPath:filePath isDirectory:NO];
    NSLog(@"%@", url);
    [self playWithURL:url];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"是否删除" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *docDir = [paths objectAtIndex:0];
        NSString *filePath = [NSString stringWithFormat:@"%@/%@", docDir, self.elements[indexPath.row]];
        NSURL *url = [NSURL fileURLWithPath:filePath isDirectory:NO];
        [[NSFileManager defaultManager] removeItemAtURL:url error:nil];
        [self reloadElements];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:action];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)playWithURL:(NSURL *)url
{
    VitamioVPVC *vc = [[VitamioVPVC alloc] initWithThemeStyle:VideoPlayerGreenButtonTheme controlBarMode:VideoPlayerControlBarWithoutPreviousAndNextOperate];
    vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:vc animated:YES completion:^{
        [vc preparePlayURL:url header:nil immediatelyPlay:YES];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
