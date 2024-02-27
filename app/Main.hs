import Data.Binary.Get
import qualified Data.ByteString.Lazy as BS
import Data.Int (Int32)
import GHC.Base
import GHC.OldList
import System.Environment
import System.Exit
import System.IO

data Point2D = Point2D
    { x :: Int32
    , y :: Int32
    }
    deriving (Eq, Ord)

instance Show Point2D where
    show (Point2D x' y') = "(" ++ show x' ++ ", " ++ show y' ++ ")"

loadPoint :: Get Point2D
loadPoint = Point2D <$> getInt32host <*> getInt32host

loadInputData :: FilePath -> IO [Point2D]
loadInputData filePath = do
    file <- BS.readFile filePath
    pure (runGet (many loadPoint) file)

orient2D :: Point2D -> Point2D -> Point2D -> Int32
orient2D a b c = (x b - x a) * (y c - y a) - (y b - y a) * (x c - x a)

buildHull :: [Point2D] -> [Point2D]
buildHull = filterHull []
  where
    filterHull :: [Point2D] -> [Point2D] -> [Point2D]
    filterHull hull@(h1 : h2 : hs) (p : ps) =
        if orient2D h2 h1 p <= 0
            then filterHull (h2 : hs) (p : ps)
            else filterHull (p : hull) ps
    filterHull hull (p : ps) = filterHull (p : hull) ps
    filterHull hull [] = reverse (tail hull)

computeConvexHull :: [Point2D] -> [Point2D]
computeConvexHull points = lowerHull ++ upperHull ++ [head sortedPoints]
  where
    sortedPoints = sort points
    lowerHull = buildHull sortedPoints -- Lower hull, from left to right
    upperHull = buildHull (reverse sortedPoints) -- Upper hull, from right to left

writeOutputToFile :: FilePath -> [Point2D] -> IO ()
writeOutputToFile outputFilename convexHull =
    withFile outputFilename WriteMode $ \handle -> mapM_ (hPrint handle) convexHull

runProgram :: FilePath -> Maybe FilePath -> IO ()
runProgram filePath maybeOutputFilename = do
    points <- loadInputData filePath
    let convexHull = computeConvexHull points
    case maybeOutputFilename of
        Just outputFilename -> writeOutputToFile outputFilename convexHull
        Nothing -> mapM_ print convexHull

main :: IO ()
main = do
    args <- getArgs
    case args of
        [filePath] -> runProgram filePath Nothing
        [filePath, outputFlag]
            | "--output=" `isPrefixOf` outputFlag ->
                let outputFilename = drop 9 outputFlag
                 in runProgram filePath (Just outputFilename)
        _ -> do
            name <- getProgName
            putStrLn $ "Usage: " ++ name ++ " input_filename [--output=output_filename]"
            exitWith (ExitFailure 1)