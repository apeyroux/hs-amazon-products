{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards   #-}

module Amazon.Types.Item
    ( ItemLookupRequest (..)
    , ItemSearchRequest (..)
    , Item (..)
    , ItemID
    , SearchIndex (..)
    , Condition (..)
    , IdType (..)
    , VariationPage (..)
    , ImageSetType (..)
    , ImageSet (..)
    , Attributes (..)
    , Dimensions (..)
    , ListPrice (..)

    , HundredthInch (..)
    , HundredthPound (..)

    , parseCondition
    , parseIdType
    , parseVariationPage

    , xpItem
    , xpItemLookupRequest
    , xpItemSearchRequest
    , xpItemId
    , xpSearchIndex
    , xpCondition
    , xpIdType
    , xpVariationPage
    , xpImageSetType
    , xpImageSet
    , xpAttributes
    , xpDimensions
    , xpListPrice

    , xpHundredthInch
    , xpHundredthPound
    ) where

import           Data.Text       as T
import           Data.XML.Pickle
import           Data.XML.Types
import           Prelude         as P

import           Amazon.Types

type ItemID  = Text

xpItemId :: PU Text ItemID
xpItemId = xpId

data SearchIndex = All
                 | Apparel
                 | Appliances
                 | ArtsAndCrafts
                 | Automotive
                 | Baby
                 | Beauty
                 | Blended
                 | Books
                 | Classical
                 | Collectibles
                 | DigitalMusic
                 | Grocery
                 | DVD
                 | Electronics
                 | HealthPersonalCare
                 | HomeGarden
                 | Industrial
                 | Jewelry
                 | KindleStore
                 | Kitchen
                 | LawnGarden
                 | Magazines
                 | Marketplace
                 | Merchants
                 | Miscellaneous
                 | MobileApps
                 | MP3Downloads
                 | Music
                 | MusicalInstruments
                 | MusicTracks
                 | OfficeProducts
                 | OutdoorLiving
                 | PCHardware
                 | PetSupplies
                 | Photo
                 | Shoes
                 | Software
                 | SportingGoods
                 | Tools
                 | Toys
                 | UnboxVideo
                 | VHS
                 | Video
                 | VideoGames
                 | Watches
                 | Wireless
                 | WirelessAccessories
                 deriving (Eq, Show, Read)

xpSearchIndex :: PU Text SearchIndex
xpSearchIndex = xpPrim

data Condition = CAll | CNew | CUsed | CCollectible | CRefurbished deriving (Eq)

instance Show Condition where
    show CAll         = "All"
    show CNew         = "New"
    show CUsed        = "Used"
    show CCollectible = "Collectible"
    show CRefurbished = "Refurbished"

parseCondition :: Text -> Condition
parseCondition "All"         = CAll
parseCondition "New"         = CNew
parseCondition "Used"        = CUsed
parseCondition "Collectible" = CCollectible
parseCondition "Refurbished" = CRefurbished

xpCondition :: PU Text Condition
xpCondition = PU { unpickleTree = return . parseCondition
                 , pickleTree   = T.pack . show
                 }

data IdType = IdASIN | IdSKU | IdUPC | IdEAN | IdISBN deriving (Eq)

instance Show IdType where
    show IdASIN = "ASIN"
    show IdSKU  = "SKU"
    show IdUPC  = "UPC"
    show IdEAN  = "EAN"
    show IdISBN = "ISBN"

parseIdType :: Text -> IdType
parseIdType "ASIN" = IdASIN
parseIdType "SKU"  = IdSKU
parseIdType "UPC"  = IdUPC
parseIdType "EAN"  = IdEAN
parseIdType "ISBN" = IdISBN

xpIdType :: PU Text IdType
xpIdType = PU { unpickleTree = return . parseIdType
              , pickleTree   = T.pack . show
              }

data VariationPage = VPAll
                   deriving (Eq)

instance Show VariationPage where
    show VPAll  = "All"

parseVariationPage :: Text -> VariationPage
parseVariationPage "All"    = VPAll

xpVariationPage :: PU Text VariationPage
xpVariationPage = PU { unpickleTree = return . parseVariationPage
                     , pickleTree   = T.pack . show
                     }

----

data ItemLookupRequest = ItemLookupRequest
        { lookupCondition      :: Condition
        , lookupIdType         :: IdType
        , lookupItemId         :: ItemID
        , lookupResponseGroups :: [ResponseGroup]
        , lookupVariationPage  :: VariationPage
        } deriving (Eq, Show)

xpItemLookupRequest :: PU [Node] ItemLookupRequest
xpItemLookupRequest =
    xpWrap (\(a, b, c, d, e) -> ItemLookupRequest a b c d e)
           (\(ItemLookupRequest a b c d e) -> (a, b, c, d, e)) $
    xp5Tuple
        (xpElemNodes (nsName "Condition") $
            xpContent xpCondition)
        (xpElemNodes (nsName "IdType") $
            xpContent xpIdType)
        (xpElemNodes (nsName "ItemId") $
            xpContent xpItemId)
        (xpList $ xpElemNodes (nsName "ResponseGroup") $
            xpContent xpResponseGroup)
        (xpElemNodes (nsName "VariationPage") $
            xpContent xpVariationPage)

instance Parameterize ItemLookupRequest where
    toParams (ItemLookupRequest{..}) =
        [ ("Condition", (T.pack $ show lookupCondition))
        , ("IdType", (T.pack $ show lookupIdType))
        , ("ItemId", lookupItemId)
        , ("ResponseGroup", intercalate "," (P.map (T.pack . show) lookupResponseGroups))
        ]

----

data ItemSearchRequest = ItemSearchRequest
        { searchCondition      :: Condition
        , searchKeywords       :: Text
        , searchResponseGroups :: [ResponseGroup]
        , searchIndex          :: SearchIndex
        , searchMaxPrice       :: Maybe Int
        , searchMinPrice       :: Maybe Int
        } deriving (Eq, Show)

xpItemSearchRequest :: PU [Node] ItemSearchRequest
xpItemSearchRequest =
    xpWrap (\(a, b, c, d, e, f) -> ItemSearchRequest a b c d e f)
           (\(ItemSearchRequest a b c d e f) -> (a, b, c, d, e, f)) $
    xp6Tuple
        (xpElemNodes (nsName "Condition") $
            xpContent xpCondition)
        (xpElemText (nsName "Keywords"))
        (xpList $ xpElemNodes (nsName "ResponseGroup") $
            xpContent xpResponseGroup)
        (xpElemNodes (nsName "SearchIndex") $
            xpContent xpSearchIndex)
        (xpElemNodes (nsName "MaximumPrice") $ xpContent xpPrim)
        (xpElemNodes (nsName "MinimumPrice") $ xpContent xpPrim)

instance Parameterize ItemSearchRequest where
    toParams (ItemSearchRequest{..}) =
        [ ("Condition", (T.pack $ show searchCondition))
        , ("Keywords", searchKeywords)
        , ("ResponseGroup", intercalate "," (P.map (T.pack . show) searchResponseGroups))
        , ("SearchIndex", (T.pack $ show searchIndex))
        ] ++ P.concatMap hPrice [ ("MaximumPrice", searchMaxPrice)
                                , ("MinimumPrice", searchMinPrice) ]
        where hPrice (_, Nothing) = []
              hPrice (n, Just  v) = [(n, (T.pack $ show v))]

----

data Item = Item
        { itemASIN       :: Text
        , itemParentASIN :: Maybe Text
        , itemAttributes :: Maybe Attributes
        , itemImageSets  :: Maybe [ImageSet]
        } deriving (Eq, Show)

xpItem :: PU [Node] Item
xpItem =
    xpWrap (\(a, b, c, d) -> Item a b c (fmap (fmap removeTuple) d))
           (\(Item a b c d) -> (a, b, c, (fmap (fmap addTuple) d))) $
    xpClean $ xp4Tuple
        (xpElemText (nsName "ASIN"))
        (xpOption $ xpElemText (nsName "ParentASIN"))
        (xpOption $ xpElemNodes (nsName "ItemAttributes") $ xpClean xpAttributes)
        (xpOption $ xpElemNodes (nsName "ImageSets") $
            xpList $ xpElem (nsName "ImageSet") (xpAttr ("Category") xpId) xpImageSet)
    where removeTuple (_,d) =     d
          addTuple       d  = ("",d)

----

data Attributes = Attributes
        { attrBinding            :: Text
        , attrBrand              :: Text
        , attrCatalogNumbers     :: Maybe [Text]
        , attrColor              :: Maybe Text
        , attrEAN                :: Int
        , attrEANList            :: [Int]
        , attrFeatures           :: [Text]
        , attrAutographed        :: Maybe Bool
        , attrEligibleForTradeIn :: Maybe Bool
        , attrMemorabilia        :: Maybe Bool
        , attrDimensions         :: Maybe Dimensions
        , attrLabel              :: Text
        , attrLegalDisclaimer    :: Maybe Text
        , attrListPrice          :: ListPrice
        , attrManufacturer       :: Maybe Text
        , attrModel              :: Maybe Text
        , attrMPN                :: Maybe Text
        , attrNumberOfItems      :: Maybe Int
        , attrPackageDimensions  :: Dimensions
        , attrPackageQuantity    :: Int
        , attrPartNumber         :: Maybe Text
        , attrProductGroup       :: Text
        , attrProductTypeName    :: Text
        , attrTitle              :: Text
        , attrUPC                :: Maybe Int
        , attrUPCList            :: Maybe [Int]
        } deriving (Eq, Show)

xpAttributes :: PU [Node] Attributes
xpAttributes =
    xpWrap (\(((((((((((((((((((((((((a, b), c), d), e), f), g), h), i), j), k), l), m), n), o), p), q), r), s), t), u), v), x), y), z), aa)
            -> Attributes a b c d e f g h i j k l m n o p q r s t u v x y z aa)
           (\(Attributes a b c d e f g h i j k l m n o p q r s t u v x y z aa)
            -> (((((((((((((((((((((((((a, b), c), d), e), f), g), h), i), j), k), l), m), n), o), p), q), r), s), t), u), v), x), y), z), aa)) $
        (xpElemText (nsName "Binding"))
    <#> (xpElemText (nsName "Brand"))
    <#> (xpOption $ xpElemNodes (nsName "CatalogNumberList") $
            xpList $ xpElemText (nsName "CatalogNumberListElement"))
    <#> (xpOption $ xpElemText (nsName "Color"))
    <#> (xpElemNodes (nsName "EAN") $ xpContent xpPrim)
    <#> (xpElemNodes (nsName "EANList") $
            xpList $ xpElemNodes (nsName "EANListElement") $ xpContent xpPrim)
    <#> (xpList $ xpElemText (nsName "Feature"))
    <#> (xpOption $ xpElemNodes (nsName "IsAutographed") $ xpContent xpTextBool)
    <#> (xpOption $ xpElemNodes (nsName "IsEligibleForTradeIn") $ xpContent xpTextBool)
    <#> (xpOption $ xpElemNodes (nsName "IsMemorabilia") $ xpContent xpTextBool)
    <#> (xpOption $ xpElemNodes (nsName "ItemDimensions") xpDimensions)
    <#> (xpElemText (nsName "Label"))
    <#> (xpOption $ xpElemText (nsName "LegalDisclaimer"))
    <#> (xpElemNodes (nsName "ListPrice") xpListPrice)
    <#> (xpOption $ xpElemText (nsName "Manufacturer"))
    <#> (xpOption $ xpElemText (nsName "Model"))
    <#> (xpOption $ xpElemText (nsName "MPN"))
    <#> (xpOption $ xpElemNodes (nsName "NumberOfItems") $ xpContent xpPrim)
    <#> (xpElemNodes (nsName "PackageDimensions") xpDimensions)
    <#> (xpElemNodes (nsName "PackageQuantity") $ xpContent xpPrim)
    <#> (xpOption $ xpElemText (nsName "PartNumber"))
    <#> (xpElemText (nsName "ProductGroup"))
    <#> (xpElemText (nsName "ProductTypeName"))
    <#> (xpElemText (nsName "Title"))
    <#> (xpOption $ xpElemNodes (nsName "UPC") $ xpContent xpPrim)
    <#> (xpOption $ xpElemNodes (nsName "UPCList") $
            xpList $ xpElemNodes (nsName "UPCListElement") $ xpContent xpPrim)

xpTextBool :: PU Text Bool
xpTextBool = PU up down
    where up "0" = return False
          up _   = return True
          down False = "0"
          down True  = "1"

----

newtype HundredthInch  = HundredthInch  Int deriving (Eq, Show)
newtype HundredthPound = HundredthPound Int deriving (Eq, Show)

xpHundredthInch :: PU Text HundredthInch
xpHundredthInch = PU (return . HundredthInch . read . T.unpack) (T.pack . show)

xpHundredthPound :: PU Text HundredthPound
xpHundredthPound = PU (return . HundredthPound . read . T.unpack) (T.pack . show)

data Dimensions = Dimensions
        { dimHeight :: Maybe HundredthInch
        , dimLength :: Maybe HundredthInch
        , dimWidth  :: Maybe HundredthInch
        , dimWeight :: Maybe HundredthPound
        } deriving (Eq, Show)

xpDimensions :: PU [Node] Dimensions
xpDimensions =
    xpWrap (\(a, b, c, d) -> Dimensions (rt a) (rt b) (rt c) (rt d))
           (\(Dimensions a b c d) -> ((at a), (at b), (at c), (at d))) $
    xp4Tuple
        (xpOption $ xpElem (nsName "Height") (xpClean $ xpOption $ xpAttr ("Units") xpId) $
            xpContent xpHundredthInch)
        (xpOption $ xpElem (nsName "Length") (xpClean $ xpOption $ xpAttr ("Units") xpId) $
            xpContent xpHundredthInch)
        (xpOption $ xpElem (nsName "Width")  (xpClean $ xpOption $ xpAttr ("Units") xpId) $
            xpContent xpHundredthInch)
        (xpOption $
            xpElem (nsName "Weight") (xpClean $ xpOption $ xpAttr (nsName "Units") xpId) $
                xpContent xpHundredthPound)
    where rt = fmap (\(_, v) -> v)
          at = fmap (\v -> (Nothing, v))

----

data ListPrice = ListPrice
        { listAmount         :: Int
        , listCurrencyCode   :: Text
        , listFormattedPrice :: Text
        } deriving (Eq, Show)

xpListPrice :: PU [Node] ListPrice
xpListPrice =
    xpWrap (\(a, b, c) -> ListPrice a b c)
           (\(ListPrice a b c) -> (a, b, c)) $
    xp3Tuple
        (xpElemNodes (nsName "Amount") $ xpContent xpPrim)
        (xpElemText (nsName "CurrencyCode"))
        (xpElemText (nsName "FormattedPrice"))

----

data ImageSetType = ISPrimary | ISVariant deriving (Eq)

instance Show ImageSetType where
    show ISPrimary = "primary"
    show ISVariant = "variant"

parseImageSetType :: Text -> ImageSetType
parseImageSetType "primary" = ISPrimary
parseImageSetType "variant" = ISVariant

xpImageSetType :: PU Text ImageSetType
xpImageSetType = PU { unpickleTree = return . parseImageSetType
                    , pickleTree   = T.pack . show
                    }

data ImageSet = ImageSet
        { isetSwatchUrl    :: Text
        , isetThumbnailUrl :: Text
        , isetTinyUrl      :: Text
        , isetSmallUrl     :: Text
        , isetMediumUrl    :: Text
        , isetLargeUrl     :: Text
        } deriving (Eq, Show)

xpImageSet :: PU [Node] ImageSet
xpImageSet =
    xpWrap (\(a, b, c, d, e, f) -> ImageSet a b c d e f)
           (\(ImageSet a b c d e f) -> (a, b, c, d, e, f)) $
    xp6Tuple
        (xpElemNodes (nsName "SwatchImage")     $ xpClean $ xpElemText (nsName "URL"))
        (xpElemNodes (nsName "ThumbnailImage")  $ xpClean $ xpElemText (nsName "URL"))
        (xpElemNodes (nsName "TinyImage")       $ xpClean $ xpElemText (nsName "URL"))
        (xpElemNodes (nsName "SmallImage")      $ xpClean $ xpElemText (nsName "URL"))
        (xpElemNodes (nsName "MediumImage")     $ xpClean $ xpElemText (nsName "URL"))
        (xpElemNodes (nsName "LargeImage")      $ xpClean $ xpElemText (nsName "URL"))
