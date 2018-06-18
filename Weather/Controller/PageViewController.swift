//
//  PageViewController.swift
//  Weather
//
//  Created by Aaron Zhong on 17/06/18.
//  Copyright © 2018 Aaron Zhong. All rights reserved.
//

import UIKit

class PageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    var myVCs = [UIViewController]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        
        let weatherVC = storyboard?.instantiateViewController(withIdentifier: "WeatherViewController") as! WeatherViewController
        
        let cityVC = storyboard?.instantiateViewController(withIdentifier: "CityViewController") as! CityViewController
        
        weatherVC.bgColourDelegate = cityVC
        cityVC.cityChangedDelegate = weatherVC
        
        cityVC.parentPageVC = self
        
        myVCs.append(weatherVC)
        
        myVCs.append(cityVC)
        
        if let firstViewController = myVCs.first {
            setViewControllers([firstViewController],
                               direction: .forward,
                               animated: true,
                               completion: nil)
        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Page View Data Source
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = myVCs.index(of: viewController) else {
            return nil
        }
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return nil
        }
        
        return myVCs[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = myVCs.index(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        
        guard nextIndex < myVCs.count else {
            return nil
        }
        
        return myVCs[nextIndex]
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
