UICollectionView-Updates
========================

A category that makes easier the use of `NSFetchedResultsController` with `UICollectionView`.

Once you have added the category to your code, you can update the collection-view as if it was a table-view, but instead of performing the update directly on the collection-view do them on the proxy.

A typical implementation of the protocol `NSFetchedResultsControllerDelegate` should be as follow:

```
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.collectionView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)object atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [[self.collectionView updateProxy] insertItemsAtIndexPaths:@[newIndexPath]];
            break;
        case NSFetchedResultsChangeDelete:
            [[self.collectionView updateProxy] deleteItemsAtIndexPaths:@[indexPath]];
            break;
        case NSFetchedResultsChangeMove:
            [[self.collectionView updateProxy] moveItemAtIndexPath:indexPath toIndexPath:newIndexPath];
            break;
        case NSFetchedResultsChangeUpdate:
            [[self.collectionView updateProxy] reloadItemsAtIndexPaths:@[indexPath]];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [[self.collectionView updateProxy] insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]];
            break;
        case NSFetchedResultsChangeDelete:
            [[self.collectionView updateProxy] deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.collectionView endUpdates];
}
```
