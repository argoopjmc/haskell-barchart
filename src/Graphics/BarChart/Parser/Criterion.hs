{-# LANGUAGE NamedFieldPuns, RecordWildCards #-}

module Graphics.BarChart.Parser.Criterion where

import Text.CSV

import System.FilePath

import Graphics.BarChart.Types
import Graphics.BarChart.Parser
import Graphics.BarChart.Rendering

-- | Used by 'writeCriterionChart' to generate a bar chart from
--   criterion's summary file.
-- 
criterionChart :: CSV -> BarChart RunTime
criterionChart (_:csv) = intervalChart $ map (take 4) csv

-- | Used by 'writeComparisonChart' to generate a bar chart from
--   multiple summary files generated by criterion.
-- 
comparisonChart :: Bool -> [(Label,CSV)] -> BarChart RunTime
comparisonChart flip
  = drawMultiBarIntervals
  . (if flip then flipMultiBarIntervals else id)
  . mergeIntervals
  . map (\ (label,_:csv) -> (label, parseIntervals $ map (take 4) csv))

-- | Reads a summary file generated by criterion and writes a
--   corresponding bar chart.
-- 
writeCriterionChart :: Config -> FilePath -> IO ()
writeCriterionChart config file =
  renderWith config . criterionChart =<< readCSV file

-- | Reads multiple summary files generated by criterion and creates a
--   bar chart to compare them. If the first argument is 'True' the
--   chart is flipped such that the bars represent different
--   benchmarks rather than summaries.
-- 
writeComparisonChart :: Bool -> Config -> [FilePath] -> IO ()
writeComparisonChart flip config@Config{..} files =
  do csvs <- mapM readCSV files
     renderWith config . comparisonChart flip $
       zip (map dropExtension files) csvs
