//
//  WalkthroughVC.swift
//  ChatApp
//
//  Created by Keyhan on 1/13/20.
//  Copyright © 2020 Advanced Technology. All rights reserved.
//

import UIKit

class WalkthroughVC: UIPageViewController {
    
    // MARK: - Private Variables
    private lazy var walkPages: [UIViewController] = {
        let firstVC: WalkthroughFirstVC = UIStoryboard(storyboard: .main).instantiateViewController()
        let secVC: WalkthroughSecVC = UIStoryboard(storyboard: .main).instantiateViewController()
        let thirdVC: WalkthroughThirdVC = UIStoryboard(storyboard: .main).instantiateViewController()
        
        return [firstVC, secVC, thirdVC]
    }()
    
    
    // MARK: - View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dataSource = self
        self.delegate   = self
        
        if let firstVC = walkPages.first {
            setViewControllers([firstVC], direction: .forward, animated: true, completion: nil)
        }
    }
}

// MARK: - UIPageViewController DataSource
extension WalkthroughVC: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        
        if let index = walkPages.firstIndex(of: viewController) {
            if index > 0 {
                return walkPages[index - 1]
            } else {
                return nil
            }
        }
        
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        
        if let index = walkPages.firstIndex(of: viewController) {
            if index < walkPages.count - 1 {
                return walkPages[index + 1]
            } else {
                return nil
            }
        }
        
        return nil
    }
}

// MARK: - UIPageViewController Delegate
extension WalkthroughVC: UIPageViewControllerDelegate {
    
}
