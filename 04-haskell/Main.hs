type Point = (Int, Int)

data Grid = Grid {
    width :: Int,
    height :: Int,
    cells :: [String]
}

get :: Grid -> Point -> Char
get grid (x, y) = cells grid !! y !! x

adjacent :: Grid -> Point -> [Char]
adjacent grid (x, y) =
    [get grid (x', y') | x' <- [x-1..x+1], y' <- [y-1..y+1],
        x' >= 0 && x' < width grid,
        y' >= 0 && y' < height grid,
        (x, y) /= (x', y')]

paperCount :: [Char] -> Int
paperCount cells = length $ filter (== '@') cells

positions :: Grid -> [Point]
positions grid = [(x, y) | x <- [0..(width grid - 1)], y <- [0..(height grid - 1)]]

paperPositions :: Grid -> [Point] -> [Point]
paperPositions grid positions = filter (\pos -> get grid pos == '@') positions

accessiblePapers :: Grid -> [Point]
accessiblePapers grid = filter ((< 4) . paperCount . adjacent grid) papers
    where papers = paperPositions grid (positions grid)

removePapers :: Grid -> [Point] -> Grid
removePapers grid accessible =
    Grid {
        width  = width grid,
        height = height grid,
        cells = cells'
    }
    -- Fuck me
    where cells' = map (\(y, row) -> replaceRow y row) (zip [0..] (cells grid))
          replaceRow y row 
            | not $ y `elem` (snd $ unzip accessible) = row
            | otherwise = map (\(x, c) -> if (x, y) `elem` accessible then '.' else c) (zip [0..] row)

        
countRemoves :: Grid -> Int -> Int
countRemoves grid count
    | null accessible = count
    | otherwise       = countRemoves (removePapers grid accessible) (count + (length accessible))
    where accessible = accessiblePapers grid

partOne :: Grid -> Int
partOne grid = length $ accessiblePapers grid

partTwo :: Grid -> Int
partTwo grid = countRemoves grid 0

inputFile = "input.txt"
main = do
    content <- lines <$> readFile inputFile
    let grid = Grid {
        width = length $ content !! 0,
        height = length content,
        cells = content
    }
    putStrLn $ "Part one: " ++ show (partOne grid)
    putStrLn $ "Part two: " ++ show (partTwo grid)
