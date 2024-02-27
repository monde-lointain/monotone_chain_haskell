import System.Environment (getArgs, getProgName)
import System.Random
import Data.Int (Int32)
import Data.Binary.Put
import qualified Data.ByteString.Lazy as BS

data Point2D = Point2D Int32 Int32

writePoint :: Point2D -> Put
writePoint (Point2D x' y') = do
    putInt32host x'
    putInt32host y'

generateRandomPoint :: Int32 -> Int32 -> IO Point2D
generateRandomPoint minVal maxVal = do
    xVal <- randomRIO (minVal, maxVal)
    yVal <- randomRIO (minVal, maxVal)
    return $ Point2D xVal yVal

main :: IO ()
main = do
    args <- getArgs
    case args of
        [nStr, minStr, maxStr, filename] -> do
            let n = read nStr :: Int
                minVal = read minStr :: Int32
                maxVal = read maxStr :: Int32
            randomPoints <- sequence $ replicate n (generateRandomPoint minVal maxVal)
            BS.writeFile filename (runPut $ mapM_ writePoint randomPoints)
            putStrLn $ "Generated " ++ show n ++ " 32-bit integer coordinates."
        _ -> do
            name <- getProgName
            putStrLn $ "Usage: " ++ name ++ " num_points min max output_filename"
