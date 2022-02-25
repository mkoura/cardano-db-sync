import           Cardano.Prelude (Text)

import           Prelude

import           Control.Monad (when, (>=>))
import           Data.Maybe (isNothing)

import           System.Directory (getCurrentDirectory)
import           System.Environment (lookupEnv, setEnv)
import           System.FilePath ((</>))

import           MigrationValidations (KnownMigration (..), knownMigrations)

import           Cardano.Mock.ChainSync.Server

import           Test.Tasty

import           Test.Cardano.Db.Mock.Unit

main :: IO ()
main = do
    -- If the env is not set, set it to default.
    mPgPassFile <- lookupEnv "PGPASSFILE"
    when (isNothing mPgPassFile) $ do
      currentDir <- getCurrentDirectory
      setEnv "PGPASSFILE" (currentDir </> "test/testfiles/pgpass-testing")
    withIOManager $
        tests >=> defaultMain

tests :: IOManager -> IO TestTree
tests iom = do
    pure $
      testGroup
        "cardano-chain-gen"
          [ unitTests iom knownMigrationsPlain
          ]
  where
    knownMigrationsPlain :: [(Text, Text)]
    knownMigrationsPlain = (\x -> (hash x, filepath x)) <$> knownMigrations