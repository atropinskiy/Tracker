//
//  StatCell.swift
//  Tracker
//
//  Created by alex_tr on 13.12.2024.
//

import UIKit

final class StatCell: UICollectionViewCell {
    var counterText: Int? {
        didSet {
            counterLabel.text = "\(counterText ?? 0)"
        }
    }
    var titleLabelText: String? {
        didSet {
            titleLabel.text = titleLabelText
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var counterLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private func setupViews () {
        [counterLabel, titleLabel].forEach{ contentView.addSubview($0) }
        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true
        
        NSLayoutConstraint.activate([
            counterLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            counterLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            counterLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
        ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let gradientLayer = CAGradientLayer()
        let thirdColor = UIColor(red: 0/255.0, green: 123/255.0, blue: 250/255.0, alpha: 1.0)
        let secondColor = UIColor(red: 70/255.0, green: 230/255.0, blue: 157/255.0, alpha: 1.0)
        let firstColor = UIColor(red: 253/255.0, green: 76/255.0, blue: 73/255.0, alpha: 1.0)
        
        gradientLayer.frame = contentView.bounds
        gradientLayer.colors = [firstColor.cgColor, secondColor.cgColor, thirdColor.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = UIBezierPath(roundedRect: contentView.bounds, cornerRadius: 16).cgPath
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor.black.cgColor // Цвет самого контурного слоя
        shapeLayer.lineWidth = 1
        
        gradientLayer.mask = shapeLayer
        
        contentView.layer.sublayers?.forEach {
            if $0 is CAGradientLayer {
                $0.removeFromSuperlayer()
            }
        }
        
        contentView.layer.insertSublayer(gradientLayer, at: 0)
    }
}

