CREATE TABLE `receipts` (
  `_id` varchar(255) PRIMARY KEY,
  `bonusPointsEarned` integer,
  `bonusPointsEarnedReason` text,
  `createDate` timestamp,
  `dateScanned` timestamp,
  `finishedDate` timestamp,
  `modifyDate` timestamp,
  `pointsAwardedDate` timestamp,
  `pointsEarned` float,
  `purchaseDate` timestamp,
  `purchasedItemCount` integer,
  `rewardsReceiptStatus` varchar(255),
  `totalSpent` float,
  `userId` varchar(255)
);

CREATE TABLE `receipt_items` (
  `receipt_id` integer,
  `partnerItemId` integer,
  `barcode` integer,
  `brandCode` varchar(255),
  `quantityPurchased` integer,
  `originalReceiptItemText` text,
  `rewardsProductPartnerId` varchar(255),
  `rewardsGroup` varchar(255),
  `competitorRewardsGroup` varchar(255),
  `pointsPayerId` varchar(255),
  `discountedItemPrice` float,
  `finalPrice` float,
  `priceAfterCoupon` float,
  `pointsEarned` float,
  `metabriteCampaignId` text,
  `needsFetchReview` bool,
  `competitiveProduct` bool,
  `targetPrice` integer,
  `preventTargetGapPoints` bool,
  `pointsNotAwardedReason` varchar(255),
  `userFlaggedBarcode` bigint,
  `userFlaggedNewItem` bool,
  `userFlaggedPrice` float,
  `userFlaggedQuantity` integer,
  `needsFetchReviewReason` varchar(255),
  `itemNumber` integer,
  `originalMetaBriteBarcode` integer,
  `originalMetaBriteQuantityPurchased` integer,
  `originalMetaBriteDescription` varchar(255),
  `originalFinalPrice` float,
  `originalMetaBriteItemPrice` float,
  `deleted` bool,
  `itemName` varchar(255),
  `itemPrice` float,
  `description` text,
  PRIMARY KEY (`receipt_id`, `partnerItemId`)
);

CREATE TABLE `users` (
  `_id` varchar(255) PRIMARY KEY,
  `active` bool,
  `createdDate` timestamp,
  `lastLogin` timestamp,
  `role` varchar(255),
  `signUpSource` varchar(255),
  `state` varchar(255)
);

CREATE TABLE `brand` (
  `_id` varchar(255) PRIMARY KEY,
  `barcode` bigint,
  `brandCode` varchar(255),
  `category` varchar(255),
  `categoryCode` varchar(255),
  `cpgID` varchar(255),
  `cpgRef` varchar(255),
  `name` varchar(255),
  `topBrand` bool
);

ALTER TABLE `receipts` ADD FOREIGN KEY (`userId`) REFERENCES `users` (`_id`);

ALTER TABLE `receipt_items` ADD FOREIGN KEY (`receipt_id`) REFERENCES `receipts` (`_id`);

ALTER TABLE `receipt_items` ADD FOREIGN KEY (`brandCode`) REFERENCES `brand` (`brandCode`);

ALTER TABLE `receipt_items` ADD FOREIGN KEY (`barcode`) REFERENCES `brand` (`barcode`);
